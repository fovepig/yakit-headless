FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    libpcap0.8 \
    ca-certificates \
    tzdata \
    wget \
    && rm -rf /var/lib/apt/lists/*

RUN wget -q -O /usr/local/bin/yak \
    https://yaklang.oss-cn-beijing.aliyuncs.com/yak/latest/yak_linux_amd64 \
    && chmod +x /usr/local/bin/yak

ENV YAKIT_HOME=/data/yakit-projects
RUN mkdir -p /data/yakit-projects

VOLUME /data/yakit-projects
EXPOSE 8087

ENTRYPOINT ["yak"]
CMD ["grpc", "--host", "0.0.0.0", "--port", "8087"]
