#!/bin/bash
set -e

echo "=== Yak Headless Docker Loader ==="
echo ""

# 1. 导入镜像
if docker image inspect yak-headless:latest > /dev/null 2>&1; then
    echo "[skip] 镜像 yak-headless:latest 已存在"
else
    echo "[1/2] 导入 Docker 镜像 (367MB)..."
    docker load -i yak-headless.tar
    echo ""
fi

# 2. 启动服务
echo "[2/2] 启动 gRPC 服务端..."
docker compose up -d
echo ""

# 3. 检查状态
sleep 3
if docker ps --filter name=yak-headless --format '{{.Status}}' | grep -q Up; then
    echo "启动成功!"
    echo ""
    echo "gRPC 服务端运行在: localhost:8087"
    echo "查看日志: docker compose logs -f"
    echo "停止服务: docker compose stop"
    echo ""
    echo "Yakit GUI 连接地址: yak://127.0.0.1:8087"
    echo ""
    echo "=== 快速测试发包 ==="
    echo 'docker exec yak-headless yak -c '"'"'rsp = http.Get("https://httpbin.org/get")~; http.show(rsp)'"'"''
else
    echo "启动失败，请查看日志: docker compose logs"
    exit 1
fi
