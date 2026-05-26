# aionui-web Docker Image

Unofficial Docker image for [AionUI](https://github.com/iOfficeAI/AionUi) Web Server (`aionui-web`), built from official Linux release binaries.

> Supports `linux/amd64` and `linux/arm64`. A new image is automatically built and pushed to Docker Hub within 6 hours of each upstream release.

---

## Quick Start

```bash
docker run -d \
  -p 3000:3000 \
  -v $(pwd)/data:/data \
  --name aionui \
  --restart unless-stopped \
  czyt/aionui:latest
```

Open [http://localhost:3000](http://localhost:3000) in your browser.

---

## Docker Compose

```yaml
services:
  aionui-web:
    image: czyt/aionui:latest
    container_name: aionui
    restart: unless-stopped
    ports:
      - "3000:3000"
    volumes:
      - ./data:/data
    environment:
      - AIONUI_PORT=3000
      - AIONUI_ALLOW_REMOTE=true
      - AIONUI_DATA_DIR=/data
      - AIONUI_LOG_DIR=/data/logs
```

```bash
docker compose up -d
```

---

## Environment Variables

| Variable | Default | Description |
|---|---|---|
| `AIONUI_PORT` | `3000` | Listening port |
| `AIONUI_ALLOW_REMOTE` | `true` | Bind `0.0.0.0` instead of `127.0.0.1`. **Must be `true` in a container.** |
| `AIONUI_DATA_DIR` | `/data` | Data directory (SQLite database, skills, etc.) |
| `AIONUI_LOG_DIR` | `/data/logs` | Log directory |
| `AIONUI_BACKEND_BIN` | *(auto)* | Override path to `aioncore` binary |

---

## Volumes

| Path | Description |
|---|---|
| `/data` | Persistent data — mount this to keep your data across container restarts |

---

## Tags

| Tag | Description |
|---|---|
| `latest` | Latest upstream release |
| `2.1.2` | Specific upstream version |

---

## Building Locally

```bash
# Clone this repo
git clone https://github.com/czyt/aionui.git
cd YOUR_REPO

# Build for your current platform
docker build --build-arg VERSION=2.1.2 -t aionui-web:2.1.2 .

# Build multi-arch (requires Docker Buildx)
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  --build-arg VERSION=2.1.2 \
  -t aionui-web:2.1.2 \
  --push .
```

> `VERSION` is required. The build will fail immediately if it is not provided.

---

## CI / Auto-Update

A GitHub Actions workflow checks for new upstream releases every 6 hours.  
When a new version is detected, it automatically:

1. Downloads the official `linux-x86_64` and `linux-arm64` binaries from the [AionUI releases page](https://github.com/iOfficeAI/AionUi/releases)
2. Builds a multi-arch Docker image
3. Pushes `:<version>` and `:latest` tags to Docker Hub

To set up in your own fork, add the following secrets under `Settings → Secrets → Actions`:

| Secret | Description |
|---|---|
| `DOCKERHUB_USERNAME` | Your Docker Hub username |
| `DOCKERHUB_TOKEN` | Docker Hub access token (not your password) |

You can also trigger a build manually from the **Actions** tab and optionally specify a version.

---

## Resetting the Admin Password

```bash
docker exec -it aionui /app/aionui-web resetpass --data-dir /data
```

---

## Disclaimer

This is an **unofficial** image and is not affiliated with or endorsed by the AionUI project.  
All rights to the AionUI software belong to [iOfficeAI](https://github.com/iOfficeAI).
