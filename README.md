# Zero-Shot 中文文本分类服务

基于 IDEA-CCNL/Erlangshen-Roberta-330M-NLI 模型的零样本文本分类API服务。

## 构建与运行Docker镜像

由于Hugging Face模型下载可能不稳定，本项目将本地已下载的模型文件**预置到Docker镜像中**，确保容器可以离线运行。

### 构建步骤

1. 首先运行预处理脚本，将模型从本地缓存复制到项目目录：

```bash
./copy_model_for_docker.sh
```

这个脚本将：
- 从您的本地 Hugging Face 缓存中复制模型文件
- 将文件放入项目的 `model_files` 目录
- 为您准备好Docker构建所需的所有文件

2. 构建Docker镜像（包含模型文件）：

```bash
docker build -t zero-shot-classifier .
```

构建过程使用多阶段构建，确保模型文件被正确打包到镜像中。

3. 运行Docker容器：

```bash
docker run -p 8000:8000 zero-shot-classifier
```

### 优势

- **完全自包含** - 镜像包含所有需要的模型文件
- **离线运行** - 不需要在运行时访问外部资源
- **部署简单** - 不需要额外的卷挂载或环境设置
- **一致性** - 确保所有环境中使用相同版本的模型

### 运行Docker容器

基本运行命令：

```bash
docker run -p 8000:8000 zero-shot-classifier
```

或者使用挂载模型目录的方式运行：

```bash
MODEL_PATH="$HOME/.cache/huggingface/hub/models--IDEA-CCNL--Erlangshen-Roberta-330M-NLI/snapshots/9ca8de565513d730f6a315337b8b0c0ae7833547"
docker run -p 8000:8000 -v "$MODEL_PATH:/app/model" zero-shot-classifier
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