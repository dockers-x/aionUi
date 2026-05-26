# -------------------------------------------------------
# AionUI Web Server - Docker Image (multi-arch: amd64 + arm64)
# Based on official Linux release binaries, no source build needed
#
# Usage:
#   docker build --build-arg VERSION=2.1.2 -t aionui-web:2.1.2 .
#   docker run -d -p 3000:3000 -v $(pwd)/data:/data --name aionui aionui-web:2.1.2
#
# VERSION is required — no default, must be passed via --build-arg in CI
# -------------------------------------------------------

FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y \
        ca-certificates \
        curl \
        libssl3 \
        libgcc-s1 \
        libc6 \
        zlib1g \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

ARG VERSION
RUN test -n "$VERSION" || (echo "ERROR: --build-arg VERSION=x.x.x is required" && exit 1)

# Map Docker TARGETARCH to AionUI release filename and bundled aioncore dir
#
#   Docker TARGETARCH | release filename suffix | aioncore subdir
#   amd64             | linux-x86_64            | linux-x64
#   arm64             | linux-arm64             | linux-arm64
#
ARG TARGETARCH
RUN case "$TARGETARCH" in \
      amd64) ARCH="x86_64"  && AIONCORE_DIR="linux-x64"  ;; \
      arm64) ARCH="arm64"   && AIONCORE_DIR="linux-arm64" ;; \
      *) echo "ERROR: Unsupported architecture: $TARGETARCH" && exit 1 ;; \
    esac \
    && URL="https://github.com/iOfficeAI/AionUi/releases/download/v${VERSION}/aionui-web-${VERSION}-linux-${ARCH}.tar.gz" \
    && echo "Downloading ${URL}" \
    && curl -fSL "$URL" -o /tmp/aionui-web.tar.gz \
    && tar -xzf /tmp/aionui-web.tar.gz -C /app --strip-components=1 \
    && rm /tmp/aionui-web.tar.gz \
    && chmod +x /app/aionui-web \
    && chmod +x /app/bundled-aioncore/${AIONCORE_DIR}/aioncore

# Persistent data directory (SQLite database, logs, skill files, etc.)
VOLUME ["/data"]

# Environment variables (confirmed from --help):
#   AIONUI_PORT         - Listen port
#   AIONUI_ALLOW_REMOTE - true = bind 0.0.0.0 instead of 127.0.0.1
#   AIONUI_DATA_DIR     - Override data directory
#   AIONUI_LOG_DIR      - Override log directory
ENV AIONUI_PORT=3000
ENV AIONUI_ALLOW_REMOTE=true
ENV AIONUI_DATA_DIR=/data
ENV AIONUI_LOG_DIR=/data/logs

EXPOSE 3000

CMD ["/app/aionui-web", "start"]
