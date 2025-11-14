# Zero-Shot 中文文本分类服务

基于 IDEA-CCNL/Erlangshen-Roberta-330M-NLI 模型的零样本文本分类API服务。

## 构建Docker镜像

由于Hugging Face模型下载可能不稳定，本项目使用本地已下载的模型文件进行Docker构建。有两种方式构建镜像：

### 方法一：使用复制脚本（推荐）

1. 首先运行提供的脚本，将模型从本地缓存复制到项目临时目录：

```bash
./copy_model_for_docker.sh
```

该脚本会将模型文件从本地 Hugging Face 缓存目录复制到项目中的临时目录。

2. 构建Docker镜像：

```bash
docker build -t zero-shot-classifier .
```

### 方法二：直接构建空模型容器，运行时挂载模型目录（推荐）

这种方法最为可靠，直接构建一个不包含模型的容器，然后在运行时通过卷挂载提供模型文件：

1. 构建基础镜像：

```bash
docker build -t zero-shot-classifier .
```

2. 运行容器时挂载本地模型目录：

```bash
# 替换为您实际的模型路径
MODEL_PATH="$HOME/.cache/huggingface/hub/models--IDEA-CCNL--Erlangshen-Roberta-330M-NLI/snapshots/9ca8de565513d730f6a315337b8b0c0ae7833547"

# 运行容器并挂载模型目录
docker run -p 8000:8000 -v "$MODEL_PATH:/app/model" zero-shot-classifier
```

这种方法的优势：
- 不需要复制模型文件，减少磁盘空间使用
- 镜像构建更快，更可靠
- 可以轻松切换不同版本的模型

### 3. 运行Docker容器

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