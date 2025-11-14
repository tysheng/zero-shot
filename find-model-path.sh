#!/bin/bash

echo "🔍 搜索可能的模型路径..."
echo "正在查找 ~/.cache/huggingface 目录中的 Erlangshen 模型..."

# 搜索所有可能的模型路径
PATHS=$(find $HOME/.cache/huggingface -path "*Erlangshen*NLI*" -type d 2>/dev/null)

if [ -z "$PATHS" ]; then
  echo "❌ 未找到匹配的模型路径"
  echo "您可能需要手动寻找模型位置，常见位置包括:"
  echo "  - $HOME/.cache/huggingface/hub/..."
  echo "  - $HOME/.local/share/huggingface/..."
  exit 1
fi

echo "✅ 找到以下可能的模型路径:"
echo "======================="

# 遍历找到的路径
while IFS= read -r path; do
  # 检查是否包含config.json(验证是否为有效的模型目录)
  if [ -f "$path/config.json" ]; then
    echo "✓ 有效模型路径: $path"

    # 查看一些模型信息
    if [ -f "$path/config.json" ]; then
      MODEL_TYPE=$(grep "model_type" "$path/config.json" | head -1)
      echo "  - 模型类型: $MODEL_TYPE"
    fi

    echo ""
    echo "使用此路径构建Docker镜像:"
    echo "./copy_model_for_docker.sh \"$path\""
    echo "======================="
  fi
done <<< "$PATHS"

echo ""
echo "选择一个有效的模型路径，然后运行相应的命令。"