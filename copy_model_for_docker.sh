#!/bin/bash
set -e

echo "🔄 开始准备模型文件 - 预置到Docker镜像中..."

# 设置模型源路径
MODEL_SOURCE="$HOME/.cache/huggingface/hub/models--IDEA-CCNL--Erlangshen-Roberta-330M-NLI/snapshots/9ca8de565513d730f6a315337b8b0c0ae7833547"

# 检查源路径是否存在
if [ ! -d "$MODEL_SOURCE" ]; then
    echo "❌ 错误：模型源路径不存在: $MODEL_SOURCE"
    echo "请确认路径是否正确，或者模型文件是否已下载。"
    exit 1
fi

# 创建模型目录
MODEL_DIR="./model_files"
mkdir -p "$MODEL_DIR"

echo "📂 正在复制模型文件到构建上下文..."
echo "   源路径: $MODEL_SOURCE"
echo "   目标路径: $MODEL_DIR"

# 复制模型文件
cp -rv "$MODEL_SOURCE"/* "$MODEL_DIR/"

# 确认文件已复制
if [ "$(ls -A $MODEL_DIR)" ]; then
    echo "✅ 模型文件已成功复制到 $MODEL_DIR/"
    echo "📦 现在可以构建Docker镜像了"
    echo "   构建命令: docker build -t zero-shot-classifier ."
    echo "   运行命令: docker run -p 8000:8000 zero-shot-classifier"
else
    echo "❌ 警告：模型文件复制失败，目录为空: $MODEL_DIR/"
    exit 1
fi

echo "🔍 复制的文件列表:"
find "$MODEL_DIR" -type f | head -n 10
echo "..."

echo "🚀 全部就绪！接下来请运行:"
echo "   docker build -t zero-shot-classifier ."