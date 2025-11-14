#!/bin/bash

# 设置模型源路径
MODEL_SOURCE="$HOME/.cache/huggingface/hub/models--IDEA-CCNL--Erlangshen-Roberta-330M-NLI/snapshots/9ca8de565513d730f6a315337b8b0c0ae7833547"

# 检查源路径是否存在
if [ ! -d "$MODEL_SOURCE" ]; then
    echo "错误：模型源路径不存在: $MODEL_SOURCE"
    echo "请确认路径是否正确，或者模型文件是否已下载。"
    exit 1
fi

# 创建临时模型目录
mkdir -p ./app/model_tmp

# 复制模型文件到临时目录
echo "正在复制模型文件到临时目录..."
cp -r $MODEL_SOURCE/* ./app/model_tmp/

# 确认文件已复制
if [ "$(ls -A ./app/model_tmp/)" ]; then
    echo "模型文件已复制到 ./app/model_tmp/，现在可以构建Docker镜像了"
    echo "构建命令: docker build -t zero-shot-classifier ."
else
    echo "警告：模型文件可能未成功复制，目录为空: ./app/model_tmp/"
    echo "可以尝试直接使用模型路径构建："
    echo "docker build -t zero-shot-classifier --build-arg MODEL_PATH=\"$MODEL_SOURCE\" ."
fi