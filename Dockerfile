
# Dockerfile

# Stage 1: 准备模型文件
FROM docker.m.daocloud.io/alpine:3.18 as model-prep

# 创建模型目录
RUN mkdir -p /tmp/model

# 设置工作目录
WORKDIR /tmp

# 将模型文件从构建上下文复制到镜像中
# 注意：构建时需要提前将模型文件复制到项目的model_files目录中
COPY ./model_files/ /tmp/model/

# Stage 2: 构建应用镜像
FROM docker.m.daocloud.io/pytorch/pytorch:2.1.0-cuda11.8-cudnn8-runtime

# 设置工作目录
WORKDIR /app

# 安装系统依赖（如 git，可选）
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    && rm -rf /var/lib/apt/lists/*

# 先仅复制 requirements.txt 以利用缓存层
COPY ./requirements.txt .

# 安装 Python 依赖（先于复制其他文件，以便缓存）
# 设置pip镜像源，加快国内下载速度
RUN pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple && \
    pip install --no-cache-dir -r requirements.txt

# 从第一阶段复制模型文件
COPY --from=model-prep /tmp/model /app/model

# 复制项目代码（分离依赖安装和代码复制，以便缓存）
COPY ./app ./app

# 设置环境变量，指示模型路径
ENV MODEL_PATH="/app/model"

# 设置模型加载路径环境变量（让 transformers 从该目录加载模型，避免网络请求）
ENV TRANSFORMERS_CACHE=/app/model
ENV HF_HOME=/app/model

# 暴露服务端口
EXPOSE 8000

# 设置Python路径以确保模块导入正常工作
ENV PYTHONPATH=/app

# 启动 FastAPI 服务
CMD uvicorn app.main:app --host 0.0.0.0 --port 8000