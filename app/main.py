# app/main.py
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List
from model_utils import ZeroShotClassifier

app = FastAPI(
    title="Zero-Shot 中文文本分类 API",
    description="基于 IDEA-CCNL/Erlangshen-Roberta-330M-NLI 的零样本分类服务",
    version="1.0.0"
)

# 初始化模型（全局单例，避免重复加载）
classifier = ZeroShotClassifier()

# 请求模型
class ZeroShotRequest(BaseModel):
    text: str
    labels: List[str]

# 响应模型
class ZeroShotResponse(BaseModel):
    text: str
    labels: List[dict]
    predicted_label: str
    predicted_score: float

@app.post("/classify", response_model=ZeroShotResponse)
def classify_endpoint(request: ZeroShotRequest):
    try:
        result = classifier.classify(request.text, request.labels)
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/")
def health():
    return {"status": "ok", "message": "Zero-Shot 分类 API 服务运行中"}