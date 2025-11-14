
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

# 从临时目录复制模型文件(如果存在)，或者直接从宿主机复制模型文件
# 两种方法二选一：1. 如果已经运行了copy_model_for_docker.sh脚本
COPY ./app/model_tmp/ /app/model/ || true

# 2. 直接从宿主机复制模型文件（如果docker build命令是在宿主机上运行）
# 注意：构建时需要添加 --build-arg MODEL_PATH="你的模型路径"
ARG MODEL_PATH=""
RUN if [ -n "$MODEL_PATH" ]; then \
      echo "Copying model from host path: $MODEL_PATH"; \
      mkdir -p /tmp/model && \
      if [ -d "$MODEL_PATH" ]; then \
        cp -r $MODEL_PATH/* /app/model/ || echo "Warning: Could not copy model files"; \
      fi \
    fi

# Step 5: 设置模型加载路径环境变量（让 transformers 从该目录加载模型，避免网络请求）
ENV TRANSFORMERS_CACHE=/app/model
ENV HF_HOME=/app/model

# Step 6: 暴露服务端口
EXPOSE 8000

# Step 7: 启动 FastAPI 服务
CMD HF_ENDPOINT=https://hf-mirror.com uvicorn app.main:app --host 0.0.0.0 --port 8000