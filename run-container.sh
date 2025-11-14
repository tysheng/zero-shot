#!/bin/bash
set -e

# 默认值
IMAGE_NAME="zero-shot-classifier"
CONTAINER_NAME="zero-shot-api"
PORT_MAPPING="9966:8000"
RESTART_POLICY="always"
MODEL_DIR=""

# 显示帮助信息
show_help() {
    echo "用法: $0 [选项...]"
    echo ""
    echo "选项:"
    echo "  -h, --help               显示此帮助信息"
    echo "  -i, --image NAME         指定Docker镜像名称 (默认: $IMAGE_NAME)"
    echo "  -n, --name NAME          指定容器名称 (默认: $CONTAINER_NAME)"
    echo "  -p, --port PORT:PORT     指定端口映射 (默认: $PORT_MAPPING 表示外部端口9966映射到容器内部8000)"
    echo "  -r, --restart POLICY     指定重启策略 (默认: $RESTART_POLICY)"
    echo "                           可选值: no, always, on-failure, unless-stopped"
    echo "  -m, --model-dir DIR      指定宿主机模型目录路径 (可选，使用卷挂载)"
    echo ""
    echo "示例:"
    echo "  $0                            # 使用默认设置启动"
    echo "  $0 -p 9966:8000              # 使用9966端口启动"
    echo "  $0 -n custom-name -r no      # 使用自定义名称且不自动重启"
    echo "  $0 --model-dir /path/to/model # 使用卷挂载模型目录"
    exit 1
}

# 解析命令行参数
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -h|--help)
            show_help
            ;;
        -i|--image)
            IMAGE_NAME="$2"
            shift
            shift
            ;;
        -n|--name)
            CONTAINER_NAME="$2"
            shift
            shift
            ;;
        -p|--port)
            PORT_MAPPING="$2"
            shift
            shift
            ;;
        -r|--restart)
            RESTART_POLICY="$2"
            shift
            shift
            ;;
        -m|--model-dir)
            MODEL_DIR="$2"
            shift
            shift
            ;;
        *)
            echo "未知参数: $1"
            show_help
            ;;
    esac
done

# 检查是否存在同名容器并停止
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "🛑 发现同名容器，正在停止并移除..."
    docker stop ${CONTAINER_NAME} > /dev/null 2>&1 || true
    docker rm ${CONTAINER_NAME} > /dev/null 2>&1 || true
    echo "✅ 已移除旧容器"
fi

# 构建运行命令
RUN_CMD="docker run -d --restart=${RESTART_POLICY} -p ${PORT_MAPPING} --name ${CONTAINER_NAME}"

# 如果指定了模型目录，则添加卷挂载
if [ ! -z "$MODEL_DIR" ]; then
    if [ ! -d "$MODEL_DIR" ]; then
        echo "❌ 错误：指定的模型目录不存在: $MODEL_DIR"
        exit 1
    fi

    # 检查模型目录是否包含config.json文件
    if [ ! -f "$MODEL_DIR/config.json" ]; then
        echo "⚠️ 警告：模型目录中未找到config.json文件，这可能导致模型加载失败"
        read -p "是否仍要继续? (y/N): " CONTINUE
        if [[ $CONTINUE != [yY] ]]; then
            echo "已取消启动"
            exit 0
        fi
    fi

    echo "📂 使用卷挂载模型目录: $MODEL_DIR"
    RUN_CMD="$RUN_CMD -v ${MODEL_DIR}:/app/model"
fi

# 完成运行命令
RUN_CMD="$RUN_CMD ${IMAGE_NAME}"

# 执行命令
echo "🚀 正在启动容器..."
echo "   - 镜像名称: ${IMAGE_NAME}"
echo "   - 容器名称: ${CONTAINER_NAME}"
echo "   - 端口映射: ${PORT_MAPPING}"
echo "   - 重启策略: ${RESTART_POLICY}"

eval $RUN_CMD
CONTAINER_ID=$(docker ps -q -f "name=${CONTAINER_NAME}")

if [ ! -z "$CONTAINER_ID" ]; then
    echo "✅ 容器启动成功！"
    echo "   - 容器ID: ${CONTAINER_ID}"
    echo "   - 访问地址: http://localhost:${PORT_MAPPING%%:*}"
    echo ""
    echo "📋 容器日志(按Ctrl+C退出):"
    docker logs -f ${CONTAINER_NAME}
else
    echo "❌ 容器启动失败"
    exit 1
fi