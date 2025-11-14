
# Dockerfile

# Step 1: 使用 PyTorch + CUDA 支持的官方镜像（支持 GPU，可替换为 CPU 镜像）
FROM docker.m.daocloud.io/pytorch/pytorch:2.1.0-cuda11.8-cudnn8-runtime

# 设置工作目录
WORKDIR /app

# 安装系统依赖（如 git，可选）
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    && rm -rf /var/lib/apt/lists/*

# Step 2: 复制项目代码
COPY ./app ./app
COPY ./requirements.txt .

# Step 3: 安装 Python 依赖
RUN pip install --no-cache-dir -r requirements.txt

# Step 4: 创建模型目录
RUN mkdir -p /app/model

# 尝试复制模型文件（如果存在）
# 我们使用WORKDIR和ADD指令，而不是COPY，更灵活
WORKDIR /app

# 添加模型文件 - 如果不存在，Docker会忽略
# 1. 尝试复制模型目录（如果存在）
ADD app/model_tmp /app/model/ 2>/dev/null || true

# 2. 直接使用挂载点(运行时通过 -v 参数挂载模型目录)
# 当容器启动时，会使用 /app/model 目录
# 如果该目录为空，则会在运行时从其他环境变量加载模型

# 设置环境变量，指示模型路径
ENV MODEL_PATH="/app/model"

# Step 5: 设置模型加载路径环境变量（让 transformers 从该目录加载模型，避免网络请求）
ENV TRANSFORMERS_CACHE=/app/model
ENV HF_HOME=/app/model

# Step 6: 暴露服务端口
EXPOSE 8000

# Step 7: 启动 FastAPI 服务
CMD HF_ENDPOINT=https://hf-mirror.com uvicorn app.main:app --host 0.0.0.0 --port 8000