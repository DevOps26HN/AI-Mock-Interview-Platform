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

def get_gemini_hint(question, role, category):
    # Using the exact model from your working curl example
    model = "gemini-flash-latest" 
    url = f"https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent"
    headers = {
        'Content-Type': 'application/json',
        'X-goog-api-key': GEMINI_API_KEY
    }
    prompt = f"Provide a concise interview hint for the following question for a {role} role in the {category} category: {question}"
    data = {
        "contents": [{
            "parts": [{"text": prompt}]
        }]
    }
    logger.info(f"Calling Gemini API for model {model}")
    try:
        response = requests.post(url, headers=headers, json=data)
        if response.status_code != 200:
            logger.error(f"Gemini API returned {response.status_code}: {response.text}")
            raise HTTPException(status_code=500, detail=f"Gemini API error: {response.text}")
        
        result = response.json()
        return result['candidates'][0]['content']['parts'][0]['text']
    except Exception as e:
        logger.error(f"Error in get_gemini_hint: {str(e)}")
        if isinstance(e, HTTPException):
            raise e
        raise HTTPException(status_code=500, detail=str(e))

def get_local_hint(question, role, category):
    return f"Local Hint: Focus on demonstrating your experience with {category} as a {role} when answering '{question}'."

@app.post("/generate-hint", response_model=HintResponse)
async def generate_hint(request: HintRequest):
    logger.info(f"Received hint request for: {request.question}")
    if GENAI_BACKEND == "gemini":
        if not GEMINI_API_KEY:
            raise HTTPException(status_code=500, detail="GEMINI_API_KEY not configured")
        hint = get_gemini_hint(request.question, request.role, request.category)
    else:
        hint = get_local_hint(request.question, request.role, request.category)
    
    return HintResponse(hint=hint)

@app.get("/health")
async def health():
    return {"status": "ok", "backend": GENAI_BACKEND}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
