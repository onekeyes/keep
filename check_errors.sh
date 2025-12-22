#!/bin/bash
# Keep 后端错误检查脚本

echo "=== Keep 后端错误检查 ==="
echo ""

# 1. 检查进程状态
echo "1. 进程状态:"
if pgrep -f "python.*keep.*api" > /dev/null; then
    PID=$(pgrep -f "python.*keep.*api" | head -1)
    echo "   ✓ 后端运行中 (PID: $PID)"
    ps -p $PID -o pid,cmd,etime,pcpu,pmem | tail -1
else
    echo "   ✗ 后端未运行"
fi
echo ""

# 2. 检查端口
echo "2. 端口监听:"
if (netstat -tlnp 2>/dev/null || ss -tlnp 2>/dev/null) | grep ":8080" > /dev/null; then
    echo "   ✓ 端口 8080 正在监听"
    (netstat -tlnp 2>/dev/null || ss -tlnp 2>/dev/null) | grep ":8080"
else
    echo "   ✗ 端口 8080 未监听"
fi
echo ""

# 3. 测试 API 连接
echo "3. API 连接测试:"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/health 2>/dev/null)
if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "404" ]; then
    echo "   ✓ API 可访问 (HTTP $HTTP_CODE)"
else
    echo "   ✗ API 不可访问 (HTTP $HTTP_CODE)"
fi
echo ""

# 4. 检查最近的错误日志
echo "4. 最近的错误 (最后 20 行):"
if [ -f "/tmp/keep_errors.log" ]; then
    tail -20 /tmp/keep_errors.log | grep -i -E "error|exception|traceback" | tail -5 || echo "   无错误日志"
else
    echo "   未找到错误日志文件"
fi
echo ""

# 5. 检查数据库连接
echo "5. 数据库连接测试:"
if command -v psql >/dev/null 2>&1; then
    DB_CONN=$(grep DATABASE_CONNECTION_STRING keep/.env 2>/dev/null | cut -d'=' -f2)
    if [ -n "$DB_CONN" ]; then
        echo "   数据库配置: $DB_CONN"
    fi
fi
echo ""

echo "=== 检查完成 ==="
