#!/bin/bash
set -e

# 确保脚本可执行
# chmod +x docker-build-cached.sh

# 定义缓存目录
CACHE_DIR="$HOME/.docker-cache"
CACHE_FILE="$CACHE_DIR/zero-shot-deps.tar"

# 创建缓存目录（如果不存在）
mkdir -p "$CACHE_DIR"

# 导入缓存（如果存在）
if [ -f "$CACHE_FILE" ]; then
  echo "🔄 正在从本地加载 Docker 构建缓存..."
  docker load < "$CACHE_FILE"
  echo "✅ 缓存加载完成"
fi

# 构建镜像，使用缓存
echo "🏗️ 开始构建镜像..."
docker build --cache-from zero-shot-classifier:latest -t zero-shot-classifier .

# 保存缓存供下次使用
echo "💾 正在保存构建缓存..."
docker save zero-shot-classifier:latest > "$CACHE_FILE"
echo "✅ 缓存已保存到 $CACHE_FILE"

echo "🚀 构建完成！可以使用以下命令运行容器："
echo "   docker run -p 9966:8000 zero-shot-classifier"