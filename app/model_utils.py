# app/model_utils.py
import torch
from transformers import AutoTokenizer, AutoModelForSequenceClassification
from typing import List, Dict, Any

class ZeroShotClassifier:
    def __init__(self, model_dir: str = None):
        import os

        # 首先尝试从环境变量获取模型路径
        if model_dir is None:
            model_dir = os.environ.get("MODEL_PATH", "/app/model")

        self.device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
        print(f"🖥️ 使用设备: {self.device}")
        print(f"📂 尝试从以下路径加载模型: {model_dir}")

        # 指定模型从本地目录加载（而非从网络）
        model_path = model_dir

        try:
            self.tokenizer = AutoTokenizer.from_pretrained(model_path)
            self.model = AutoModelForSequenceClassification.from_pretrained(model_path).to(self.device)
            self.model.eval()
            print("✅ 模型加载成功")
        except Exception as e:
            print(f"❌ 模型加载失败: {str(e)}")
            print("⚠️ 请确认以下几点:")
            print("  1. 模型文件是否已复制到Docker镜像中")
            print("  2. 是否使用了正确的模型路径")
            print("  3. 或者考虑使用卷挂载: docker run -v 本地模型路径:/app/model ...")
            raise

    def classify(self, text: str, labels: List[str]) -> Dict[str, Any]:
        results = []

        for label in labels:
            inputs = self.tokenizer(
                text,
                label,
                return_tensors="pt",
                truncation=True,
                padding=True
            ).to(self.device)

            with torch.no_grad():
                logits = self.model(**inputs).logits
                probs = torch.nn.functional.softmax(logits, dim=1)[0]  # [entailment, neutral, contradiction]

            # 假设 NLI 模型输出顺序是 [entailment, neutral, contradiction]
            # 取第0个值（entailment）作为该文本与标签的匹配度
            entailment_score = probs[0].item()
            results.append({
                "label": label,
                "score": entailment_score
            })

        # 按得分降序排序
        sorted_results = sorted(results, key=lambda x: x["score"], reverse=True)
        best_label = sorted_results[0]["label"]
        best_score = sorted_results[0]["score"]

        return {
            "text": text,
            "labels": sorted_results,
            "predicted_label": best_label,
            "predicted_score": best_score
        }