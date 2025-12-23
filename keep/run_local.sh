#!/bin/bash

# Keep 本地运行脚本
# 设置环境变量并启动 Keep 后端服务

# 获取脚本所在目录（keep/keep）
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# 切换到项目根目录（keep/keep 的上一级）
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"

# 查找 .env 文件（在项目根目录或 keep 目录）
ENV_FILE=""
if [ -f "$PROJECT_ROOT/.env" ]; then
    ENV_FILE="$PROJECT_ROOT/.env"
elif [ -f "$PROJECT_ROOT/keep/.env" ]; then
    ENV_FILE="$PROJECT_ROOT/keep/.env"
fi

# 如果存在 .env 文件，加载环境变量
if [ -n "$ENV_FILE" ] && [ -f "$ENV_FILE" ]; then
    echo "从 .env 文件加载环境变量: $ENV_FILE"
    set -a
    source "$ENV_FILE"
    set +a
else
    echo "错误: .env 文件不存在"
    echo "请创建 .env 文件并配置必要的环境变量"
    echo "可以在项目根目录 ($PROJECT_ROOT) 或 keep 目录 ($PROJECT_ROOT/keep) 创建 .env 文件"
    exit 1
fi

# 创建必要的目录
mkdir -p state
mkdir -p /tmp/prometheus

# 检查 Poetry 是否已安装依赖
if [ ! -d ".venv" ] && [ ! -f "poetry.lock" ]; then
    echo "正在安装依赖..."
    poetry install
fi

# 启动 Keep API
echo "正在启动 Keep 后端服务..."
echo "端口: $PORT"
echo "API URL: $KEEP_API_URL"
echo "数据库: $DATABASE_CONNECTION_STRING"
echo "认证类型: $AUTH_TYPE"
echo "Redis: $REDIS ($REDIS_HOST:$REDIS_PORT)"

# 直接使用 uvicorn 运行，避免 CLI 参数覆盖环境变量
# 确保在项目根目录，并设置 Python 路径
cd "$PROJECT_ROOT"
export PYTHONPATH="$PROJECT_ROOT:$PYTHONPATH"
export PYTHONUNBUFFERED=1  # 禁用 Python 输出缓冲，确保日志实时显示

echo ""
echo "=========================================="
echo "Keep 后端服务启动信息"
echo "=========================================="
echo "项目根目录: $PROJECT_ROOT"
echo "Python 路径: $PYTHONPATH"
echo "工作目录: $(pwd)"
echo "=========================================="
echo ""

# 优先使用 Poetry 环境（确保依赖完整）
if command -v poetry >/dev/null 2>&1 && poetry env info >/dev/null 2>&1; then
    echo "[INFO] 使用 Poetry 虚拟环境运行..."
    POETRY_ENV=$(poetry env info --path 2>/dev/null || echo "未知")
    echo "[INFO] Poetry 环境路径: $POETRY_ENV"
    echo ""
    echo "[INFO] 正在启动 Keep API..."
    echo "[INFO] 日志输出开始..."
    echo ""
    poetry run python3 -u -c "
import sys
import os
import logging

# 配置日志格式
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s [%(levelname)s] %(name)s: %(message)s',
    datefmt='%Y-%m-%d %H:%M:%S'
)

# 确保项目根目录在路径中
project_root = os.getcwd()
if project_root not in sys.path:
    sys.path.insert(0, project_root)

print(f'[INFO] Python 版本: {sys.version}')
print(f'[INFO] Python 路径: {sys.path[:3]}...')
print(f'[INFO] 工作目录: {os.getcwd()}')
print('[INFO] 正在导入 keep.api...')

try:
    from keep.api import api
    print('[INFO] keep.api 导入成功')
    print('[INFO] 正在创建应用实例...')
    app = api.get_app()
    print('[INFO] 应用实例创建成功')
    print('[INFO] 正在启动服务器...')
    print('')
    api.run(app)
except Exception as e:
    print(f'[ERROR] 启动失败: {e}')
    import traceback
    traceback.print_exc()
    sys.exit(1)
" 2>&1
elif [ -n "$VIRTUAL_ENV" ]; then
    echo "检测到虚拟环境: $VIRTUAL_ENV"
    echo "检查依赖是否完整..."
    # 检查关键依赖
    if ! python3 -c "import arq" 2>/dev/null; then
        echo "错误: 虚拟环境中缺少依赖 arq"
        echo "请使用 Poetry 环境运行（推荐）:"
        echo "  poetry run python3 -c \"from keep.api import api; app = api.get_app(); api.run(app)\""
        exit 1
    fi
    echo ""
    echo "[INFO] 正在启动 Keep API..."
    echo "[INFO] 日志输出开始..."
    echo ""
    # 使用 python3 运行
    python3 -u -c "
import sys
import os
import logging

# 配置日志格式
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s [%(levelname)s] %(name)s: %(message)s',
    datefmt='%Y-%m-%d %H:%M:%S'
)

# 确保项目根目录在路径中
project_root = os.getcwd()
if project_root not in sys.path:
    sys.path.insert(0, project_root)

print(f'[INFO] Python 版本: {sys.version}')
print(f'[INFO] Python 路径: {sys.path[:3]}...')
print(f'[INFO] 工作目录: {os.getcwd()}')
print('[INFO] 正在导入 keep.api...')

try:
    from keep.api import api
    print('[INFO] keep.api 导入成功')
    print('[INFO] 正在创建应用实例...')
    app = api.get_app()
    print('[INFO] 应用实例创建成功')
    print('[INFO] 正在启动服务器...')
    print('')
    api.run(app)
except Exception as e:
    print(f'[ERROR] 启动失败: {e}')
    import traceback
    traceback.print_exc()
    sys.exit(1)
" 2>&1
else
    echo "未检测到虚拟环境，使用 Poetry 运行..."
    echo ""
    echo "[INFO] 正在启动 Keep API..."
    echo "[INFO] 日志输出开始..."
    echo ""
    poetry run python3 -u -c "
import sys
import os
import logging

# 配置日志格式
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s [%(levelname)s] %(name)s: %(message)s',
    datefmt='%Y-%m-%d %H:%M:%S'
)

# 确保项目根目录在路径中
project_root = os.getcwd()
if project_root not in sys.path:
    sys.path.insert(0, project_root)

print(f'[INFO] Python 版本: {sys.version}')
print(f'[INFO] Python 路径: {sys.path[:3]}...')
print(f'[INFO] 工作目录: {os.getcwd()}')
print('[INFO] 正在导入 keep.api...')

try:
    from keep.api import api
    print('[INFO] keep.api 导入成功')
    print('[INFO] 正在创建应用实例...')
    app = api.get_app()
    print('[INFO] 应用实例创建成功')
    print('[INFO] 正在启动服务器...')
    print('')
    api.run(app)
except Exception as e:
    print(f'[ERROR] 启动失败: {e}')
    import traceback
    traceback.print_exc()
    sys.exit(1)
" 2>&1
fi

