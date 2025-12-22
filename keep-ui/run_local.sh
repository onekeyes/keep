#!/bin/bash

# Keep UI 本地运行脚本
# 设置环境变量并启动 Next.js 开发服务器

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

# 如果存在 .env.local 文件，加载环境变量
if [ -f .env.local ]; then
    echo "从 .env.local 文件加载环境变量..."
    set -a
    source .env.local
    set +a
else
    echo "警告: .env.local 文件不存在"
    exit 1
fi

# 检查 Node.js 和 npm 是否安装
if ! command -v node >/dev/null 2>&1; then
    echo "错误: 未找到 Node.js，请先安装 Node.js"
    exit 1
fi

if ! command -v npm >/dev/null 2>&1; then
    echo "错误: 未找到 npm，请先安装 npm"
    exit 1
fi

# 检查依赖是否已安装
if [ ! -d "node_modules" ]; then
    echo "正在安装依赖..."
    npm install
fi

# 显示配置信息
echo "正在启动 Keep UI 前端服务..."
echo "API URL: $NEXT_PUBLIC_API_URL"
echo "NextAuth URL: $NEXTAUTH_URL"
echo "Pusher: $PUSHER_HOST:$PUSHER_PORT"
echo ""

# 获取端口号（从环境变量或默认 3000）
PORT=${PORT:-3000}
echo "使用端口: $PORT"
echo ""

# 启动 Next.js 开发服务器
# 先构建 monaco workers，然后使用环境变量中的端口启动开发服务器
npm run build-monaco-workers && npx next dev --turbopack -p "$PORT"

