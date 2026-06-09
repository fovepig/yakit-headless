# Yak Headless - Yakit 无头模式 Docker 镜像

Yakit 后端引擎 (yak) 的 Docker 化部署，无需 GUI，纯命令行使用。

## 快速开始（从源码构建）

```bash
make build          # 构建镜像
make test           # 测试二进制
make run            # 启动 gRPC 服务端
make logs           # 查看日志
make stop           # 停止
make export         # 导出镜像 tar 包，用于分享
```

## 分享给他人

将以下 4 个文件发给对方，放到同一目录下：

```
yak-headless.tar        # Docker 镜像 (367MB)
docker-compose.yml      # 服务编排
load-and-run.sh         # 一键导入并启动
README.md               # 本文件
```

接收方只需一行命令：

```bash
bash load-and-run.sh
```

脚本会自动加载镜像、启动服务、验证状态。对方不需要任何 Dockerfile 构建知识。

如果接收方想手动操作：

```bash
# 1. 导入镜像
docker load -i yak-headless.tar

# 2. 启动
docker compose up -d

# 3. 查看状态
docker compose logs -f
```

## CLI 发包

### 一行式发 HTTP 请求

```bash
# GET 请求
docker run --rm yak-headless -c 'rsp = http.Get("https://httpbin.org/get")~; http.show(rsp)'

# POST JSON（原始报文）
docker run --rm yak-headless -c '
rsp, req = poc.HTTPEx(`POST /post HTTP/1.1
Host: httpbin.org
Content-Type: application/json

{"hello":"world"}`, poc.https(true))~
println(string(rsp.RawPacket))
'
```

### 在运行中的容器发包

```bash
# 使用 docker exec
docker exec yak-headless yak -c 'rsp = http.Get("https://httpbin.org/get")~; http.show(rsp)'
```

### 脚本文件

```bash
cat > test.yak << 'EOF'
rsp, req = poc.HTTPEx(`GET / HTTP/1.1
Host: example.com

`, poc.https(true), poc.timeout(15))~

println("Status:", rsp.GetStatusCode())
println(string(rsp.RawPacket))
EOF

docker run --rm -v $(pwd):/scripts yak-headless run /scripts/test.yak
```

### 带代理

```bash
docker run --rm yak-headless -c '
rsp = poc.Get("https://httpbin.org/get",
    poc.proxy("http://127.0.0.1:8080"),
    poc.timeout(30),
)~
http.show(rsp)
'
```

## gRPC 服务端模式

启动后可通过 gRPC (端口 8087) 连接，配合 Yakit GUI 使用：

```bash
# 无密码（docker-compose.yml 默认）
docker compose up -d

# 带密码认证
docker compose up -d
# 然后修改 docker-compose.yml，取消 command 那行的注释并设置密码
```

Yakit GUI 连接地址：`yak://<服务器IP>:8087` 或 `yak://127.0.0.1:8087`

## 数据持久化

容器内数据目录 `/data/yakit-projects` 通过 volume 挂载到 `./yak-data/`。

首次启动会初始化 SQLite 数据库和插件（约 15 秒），后续启动因为数据已持久化会快很多。
