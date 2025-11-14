#!/bin/bash

# 创建临时模型目录
mkdir -p ./app/model_tmp

# 复制模型文件到临时目录
echo "正在复制模型文件到临时目录..."
cp -r ~/.cache/huggingface/hub/models--IDEA-CCNL--Erlangshen-Roberta-330M-NLI/snapshots/9ca8de565513d730f6a315337b8b0c0ae7833547/* ./app/model_tmp/

echo "模型文件已复制到 ./app/model_tmp/，现在可以构建Docker镜像了"
echo "构建命令: docker build -t zero-shot-classifier ."