from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field
import os
import requests
import json
import logging
import traceback
from prometheus_fastapi_instrumentator import Instrumentator
from prometheus_client import Counter

# Configure logging to be more descriptive
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger("genai-service")

app = FastAPI()
Instrumentator().instrument(app).expose(app)

# Custom Prometheus metrics for tracking request routing and fallback rates
genai_requests_total = Counter(
    "genai_requests_total",
    "Total requests to GenAI hint generator, partitioned by backend and source",
    ["backend", "source"]
)

class HintRequest(BaseModel):
    question: str = Field(..., max_length=2000)
    role: str = Field(..., max_length=100)
    category: str = Field(..., max_length=100)

class HintResponse(BaseModel):
    hint: str
    source: str

GENAI_BACKEND = os.getenv("GENAI_BACKEND", "local")
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY", "")
GEMINI_MODEL = os.getenv("GENAI_MODEL", "gemini-flash-lite-latest")
LOCAL_MODEL_URL = os.getenv("LOCAL_MODEL_URL", "http://localhost:11434/api/generate")

def get_gemini_hint(question, role, category):
    url = f"https://generativelanguage.googleapis.com/v1beta/models/{GEMINI_MODEL}:generateContent"
    headers = {
        'Content-Type': 'application/json',
        'X-goog-api-key': GEMINI_API_KEY
    }

    # Explicitly requesting plain text without markdown
    prompt = (
        f"Provide a concise interview hint for the following question for a {role} role in the {category} category: {question}. "
        "Return ONLY the hint text. Do NOT use markdown, bolding (**), or bullet points. "
        "Keep it professional and structured as a clear paragraph."
    )
    data = {
        "contents": [{
            "parts": [{"text": prompt}]
        }]
    }
    
    logger.info(f">>> Requesting hint from Gemini ({GEMINI_MODEL})")
    try:
        response = requests.post(url, headers=headers, json=data, timeout=15)
        
        if response.status_code == 200:
            result = response.json()
            try:
                text = result['candidates'][0]['content']['parts'][0]['text']
                logger.info("<<< Gemini hint generated successfully.")
                return text
            except (KeyError, IndexError) as e:
                logger.error(f"!!! Unexpected Gemini response structure: {json.dumps(result)}")
                raise HTTPException(status_code=500, detail="Unexpected Gemini response structure")
        else:
            logger.error(f"!!! Gemini API Error {response.status_code}: {response.text}")
            raise HTTPException(status_code=response.status_code, detail=f"Gemini API Error: {response.text}")
            
    except requests.exceptions.Timeout:
        logger.error("!!! Gemini API request timed out after 15s")
        raise HTTPException(status_code=504, detail="Gemini API request timed out")
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"!!! Exception in get_gemini_hint: {str(e)}")
        logger.error(traceback.format_exc())
        raise HTTPException(status_code=500, detail=str(e))

def get_local_hint(question, role, category):
    logger.info(f">>> Attempting local inference via Ollama at {LOCAL_MODEL_URL}")
    # Explicitly requesting plain text without markdown
    prompt = (
        f"Provide a concise interview hint for the following question for a {role} role in the {category} category: {question}. "
        "Return ONLY the hint text. Do NOT use markdown, bolding (**), or bullet points. "
        "Keep it professional and structured as a clear paragraph."
    )

    payload = {
        "model": "llama3",
        "prompt": prompt,
        "stream": False
    }

    try:
        response = requests.post(LOCAL_MODEL_URL, json=payload, timeout=10)
        if response.status_code == 200:
            logger.info("<<< Local hint generated successfully.")
            return response.json().get("response", "No response from local model")
        else:
            logger.warning(f"!!! Local Ollama returned status {response.status_code}")
            return None
    except Exception as e:
        logger.warning(f"!!! Local Ollama service not reachable: {str(e)}")
        return None

@app.post("/generate-hint", response_model=HintResponse)
async def generate_hint(request: HintRequest):
    logger.info(f"=== New Hint Request: {request.question[:50]}... ===")
    
    if GENAI_BACKEND == "gemini":
        if not GEMINI_API_KEY:
            logger.error("!!! GENAI_BACKEND is 'gemini' but GEMINI_API_KEY is missing!")
            raise HTTPException(status_code=500, detail="GEMINI_API_KEY is missing")
        
        try:
            hint = get_gemini_hint(request.question, request.role, request.category)
            genai_requests_total.labels(backend="gemini", source="gemini").inc()
            return HintResponse(hint=hint, source="gemini")
        except HTTPException as he:
            logger.info(f"--- Gemini failed ({he.status_code}), checking local.")
            # Try local model as fallback
            hint = get_local_hint(request.question, request.role, request.category)
            if hint:
                genai_requests_total.labels(backend="gemini", source="local").inc()
                return HintResponse(hint=hint, source="local")
            
            # If everything fails, return a simulated hint to maintain UX
            logger.warning("!!! All AI backends failed. Returning simulated hint.")
            simulated_hint = (
                f"For this {request.category} question ({request.role}), "
                f"focus on demonstrating your understanding of '{request.question[:40]}...'. "
                "Try to provide a concrete example from your experience."
            )
            genai_requests_total.labels(backend="gemini", source="simulated").inc()
            return HintResponse(hint=simulated_hint, source="simulated")
    
    # Direct local path
    hint = get_local_hint(request.question, request.role, request.category)
    if not hint:
        logger.error("!!! All inference methods failed.")
        raise HTTPException(status_code=503, detail="AI Hint service currently unavailable")
    
    genai_requests_total.labels(backend="local", source="local").inc()
    return HintResponse(hint=hint, source="local")

@app.get("/health")
async def health():
    return {
        "status": "ok", 
        "backend": GENAI_BACKEND, 
        "model": GEMINI_MODEL,
        "has_key": bool(GEMINI_API_KEY)
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
