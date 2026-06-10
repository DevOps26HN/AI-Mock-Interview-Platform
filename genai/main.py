from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import os
import requests
import json
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI()

class HintRequest(BaseModel):
    question: str
    role: str
    category: str

class HintResponse(BaseModel):
    hint: str

GENAI_BACKEND = os.getenv("GENAI_BACKEND", "local")
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY", "")
LOCAL_MODEL_URL = os.getenv("LOCAL_MODEL_URL", "http://localhost:11434/api/generate")

def get_gemini_hint(question, role, category):
    # Using gemini-2.5-flash which was verified to work with the provided key
    model = "gemini-2.5-flash" 
    url = f"https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent?key={GEMINI_API_KEY}"
    headers = {
        'Content-Type': 'application/json'
    }
    prompt = f"Provide a concise interview hint for the following question for a {role} role in the {category} category: {question}"
    data = {
        "contents": [{
            "parts": [{"text": prompt}]
        }]
    }
    logger.info(f"Calling Gemini API for model {model}")
    try:
        response = requests.post(url, headers=headers, json=data, timeout=15)
        if response.status_code != 200:
            logger.error(f"Gemini API returned {response.status_code}: {response.text}")
            raise Exception(f"Gemini API error: {response.status_code}")
        
        result = response.json()
        return result['candidates'][0]['content']['parts'][0]['text']
    except Exception as e:
        logger.error(f"Error in get_gemini_hint: {str(e)}")
        raise e

def get_local_hint(question, role, category):
    logger.info(f"Attempting local inference via Ollama at {LOCAL_MODEL_URL}")
    prompt = f"Provide a concise interview hint for the following question for a {role} role in the {category} category: {question}"
    
    payload = {
        "model": "llama3",
        "prompt": prompt,
        "stream": False
    }
    
    try:
        response = requests.post(LOCAL_MODEL_URL, json=payload, timeout=10)
        if response.status_code == 200:
            return response.json().get("response", "No response from local model")
    except Exception as e:
        logger.warning(f"Local Ollama service not reachable: {str(e)}")
    
    return f"[Fallback Hint]: For a {role} answering '{question}', focus on your practical experience in {category}."

@app.post("/generate-hint", response_model=HintResponse)
async def generate_hint(request: HintRequest):
    logger.info(f"Received hint request for: {request.question}")
    
    hint = None
    if GENAI_BACKEND == "gemini":
        if not GEMINI_API_KEY:
            logger.warning("GEMINI_API_KEY not configured. Falling back.")
        else:
            try:
                hint = get_gemini_hint(request.question, request.role, request.category)
            except Exception as e:
                logger.error(f"Gemini API failed: {str(e)}. Falling back.")
    
    if not hint:
        hint = get_local_hint(request.question, request.role, request.category)
    
    return HintResponse(hint=hint)

@app.get("/health")
async def health():
    return {"status": "ok", "backend": GENAI_BACKEND}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
