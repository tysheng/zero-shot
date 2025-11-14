# Zero-Shot 中文文本分类服务

基于 IDEA-CCNL/Erlangshen-Roberta-330M-NLI 模型的零样本文本分类API服务。

## 构建与运行Docker镜像

由于Hugging Face模型下载可能不稳定，本项目将本地已下载的模型文件**预置到Docker镜像中**，确保容器可以离线运行。

### 构建步骤

1. 首先查找并复制模型文件到项目目录：

**查找模型路径**:
```bash
# 自动查找可能的模型路径
./find-model-path.sh
```

这个脚本会帮您在本地查找所有可能的模型路径，并提供使用指令。

**复制模型文件**:
```bash
# 方法A: 使用自动查找的路径
./copy_model_for_docker.sh "找到的模型路径"

# 方法B: 使用默认路径(如果模型确实在默认位置)
./copy_model_for_docker.sh
```

这个脚本将：
- 从您指定的模型路径复制文件
- 将文件放入项目的 `model_files` 目录
- 验证复制的模型文件是否完整
- 为您准备好Docker构建所需的所有文件

**常见问题排查**:
如果默认路径不存在，脚本会自动尝试查找其他可能的路径。如果仍然找不到，您需要手动指定正确的路径。

2. 构建Docker镜像（包含模型文件）：

**标准构建方式：**
```bash
docker build -t zero-shot-classifier .
```

**加速构建方式（推荐）：**
```bash
# 使用缓存加速脚本构建，避免重复下载依赖
./docker-build-cached.sh
```

加速脚本会自动保存和加载Docker构建缓存，大大减少重复构建时的下载时间。构建过程使用多阶段构建，确保模型文件被正确打包到镜像中。

3. 运行Docker容器：

```bash
# 使用增强版启动脚本，支持自动重启、指定名称等
./run-container.sh
```

**高级用法：**
```bash
# 自定义端口、容器名称和重启策略
./run-container.sh -p 9966:8000 -n my-classifier -r always

# 显示所有可用选项
./run-container.sh --help
```

启动脚本支持以下选项：
- `-p, --port PORT:PORT`：指定端口映射（默认：9966:8000）
- `-n, --name NAME`：设置容器名称（默认：zero-shot-api）
- `-r, --restart POLICY`：设置重启策略（默认：always）
- `-m, --model-dir DIR`：使用本地模型目录（可选）

### 优势

- **完全自包含** - 镜像包含所有需要的模型文件
- **离线运行** - 不需要在运行时访问外部资源
- **自动重启** - 容器崩溃或系统重启时自动恢复服务
- **部署简单** - 提供友好的启动脚本，支持多种配置选项
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