# Zero-Shot 中文文本分类服务

基于 IDEA-CCNL/Erlangshen-Roberta-330M-NLI 模型的零样本文本分类API服务。

## 构建Docker镜像

由于Hugging Face模型下载可能不稳定，本项目使用本地已下载的模型文件进行Docker构建。

### 1. 复制模型文件

首先运行提供的脚本，将模型从本地缓存复制到项目临时目录：

```bash
./copy_model_for_docker.sh
```

这个脚本会将模型文件从`~/.cache/huggingface/hub/models--IDEA-CCNL--Erlangshen-Roberta-330M-NLI/snapshots/9ca8de565513d730f6a315337b8b0c0ae7833547/`复制到`./app/model_tmp/`目录。

### 2. 构建Docker镜像

```bash
docker build -t zero-shot-classifier .
```

### 3. 运行Docker容器

```bash
docker run -p 8000:8000 zero-shot-classifier
```

服务将在 http://localhost:8000 上运行。

## API接口

### 1. 健康检查

```
GET /
```

### 2. 文本分类

```
POST /classify
```

请求体示例：

```json
{
  "text": "这个手机的屏幕非常漂亮，但电池续航一般",
  "labels": ["正面评价", "负面评价", "中性评价"]
}
```

响应示例：

```json
{
  "text": "这个手机的屏幕非常漂亮，但电池续航一般",
  "labels": [
    {
      "label": "中性评价",
      "score": 0.85
    },
    {
      "label": "正面评价",
      "score": 0.45
    },
    {
      "label": "负面评价",
      "score": 0.12
    }
  ],
  "predicted_label": "中性评价",
  "predicted_score": 0.85
}
```