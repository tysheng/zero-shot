#!/bin/bash
set -e

echo "🔄 开始准备模型文件 - 预置到Docker镜像中..."

# 设置模型源路径
MODEL_SOURCE="$HOME/.cache/huggingface/hub/models--IDEA-CCNL--Erlangshen-Roberta-330M-NLI/snapshots/9ca8de565513d730f6a315337b8b0c0ae7833547"

# 检查源路径是否存在
if [ ! -d "$MODEL_SOURCE" ]; then
    # 如果原始路径不存在，尝试其他可能的路径
    echo "⚠️ 警告：原始模型路径不存在，尝试其他可能路径..."

    # 尝试查找可能的路径
    POSSIBLE_PATHS=$(find $HOME/.cache/huggingface -type d -name "*Erlangshen*NLI*" 2>/dev/null)

    if [ -z "$POSSIBLE_PATHS" ]; then
        echo "❌ 错误：在缓存中找不到匹配的模型路径"
        echo "请手动指定模型路径:"
        echo "./copy_model_for_docker.sh /path/to/model"
        exit 1
    else
        # 使用找到的第一个路径
        MODEL_SOURCE=$(echo "$POSSIBLE_PATHS" | head -n 1)
        echo "✅ 找到可能的模型路径: $MODEL_SOURCE"
    fi
fi

# 支持从命令行参数传入模型路径
if [ ! -z "$1" ]; then
    MODEL_SOURCE="$1"
    echo "ℹ️ 使用命令行指定的模型路径: $MODEL_SOURCE"
fi

echo "🔍 确认模型文件是否存在..."
if [ ! -f "$MODEL_SOURCE/config.json" ]; then
    echo "❌ 错误：在 $MODEL_SOURCE 中找不到 config.json 文件"
    echo "这可能不是一个有效的 Hugging Face 模型目录"
    echo "请指定正确的模型路径: ./copy_model_for_docker.sh /path/to/model"
    exit 1
fi

# 创建模型目录
MODEL_DIR="./model_files"
mkdir -p "$MODEL_DIR"

echo "📂 正在复制模型文件到构建上下文..."
echo "   源路径: $MODEL_SOURCE"
echo "   目标路径: $MODEL_DIR"

# 复制模型文件并保持权限
cp -rv "$MODEL_SOURCE"/* "$MODEL_DIR/"

# 确认文件已复制
if [ "$(ls -A $MODEL_DIR)" ]; then
    echo "✅ 模型文件已成功复制到 $MODEL_DIR/"

    # 确认config.json是否存在
    if [ -f "$MODEL_DIR/config.json" ]; then
        echo "✅ config.json 文件已确认存在"
    else
        echo "❌ 错误：config.json 文件未找到，这可能会导致模型加载失败"
        ls -la "$MODEL_DIR"
        exit 1
    fi

    echo "📦 现在可以构建Docker镜像了"
    echo "   构建命令: docker build -t zero-shot-classifier ."
    echo "   运行命令: docker run -p 8000:8000 zero-shot-classifier"
else
    echo "❌ 警告：模型文件复制失败，目录为空: $MODEL_DIR/"
    exit 1
fi

echo "🔍 复制的文件列表:"
find "$MODEL_DIR" -type f | sort | head -n 20
echo "..."
echo "总文件数: $(find "$MODEL_DIR" -type f | wc -l)"

echo "🚀 全部就绪！接下来请运行:"
echo "   docker build -t zero-shot-classifier ."