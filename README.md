# Llama 3.2 1B CPU Inference Server (Ollama + Docker)

Run **Meta Llama 3.2 1B** as a lightweight inference server on a cheap cloud VM using **Ollama and Docker**.

This setup allows you to deploy a **self-hosted LLM API without GPUs**, suitable for automation pipelines, report generation systems, and internal AI tools.

---

# Overview

This repository contains a minimal setup to run a **CPU-based LLM inference node**.

Architecture:

```
Client / AI pipeline
        ↓
HTTP API
        ↓
Ollama inference server
        ↓
Llama 3.2 1B model
```

The container preloads the model during build so the VM is ready for inference immediately after startup.

---

# Tested Environment

Example deployment used:

```
Cloud VM
4 vCPU
16GB RAM
Ubuntu
No GPU
```

Performance observed:

```
~10–15 tokens/sec
```

Cold start:

```
~15–20 seconds
```

Typical generation time per section:

```
15–25 seconds
```

---

# Repository Structure

```
.
├── docker-compose.yml
├── Dockerfile
└── README.md
```

---

# docker-compose.yml

Runs the Ollama inference server and exposes the API.

```yaml
version: "3.9"

services:
  ollama:
    build: .
    container_name: ollama-service
    restart: always

    ports:
      - "11434:11434"

    environment:
      - OLLAMA_HOST=0.0.0.0

    volumes:
      - ollama_storage:/root/.ollama

    deploy:
      resources:
        limits:
          cpus: "3.0"
          memory: 4G

volumes:
  ollama_storage:
```

Key features:

```
Persistent model storage
CPU + memory limits
Public API access
```

---

# Dockerfile

Preloads the model so the live VM does not need to download it on first request.

```dockerfile
FROM ollama/ollama:latest

# Pre-loading the model so the live VM doesn't struggle later
RUN nohup bash -c "ollama serve &" && \
    sleep 5 && \
    ollama pull llama3.2:1b && \
    pkill ollama

EXPOSE 11434

ENTRYPOINT ["ollama", "serve"]
```

---

# Start the Inference Server

Build and start the container.

```
docker compose up -d
```

Verify container is running:

```
docker ps
```

---

# API Endpoint

Once running, the Ollama API will be available at:

```
http://SERVER_IP:11434
```

---

# Test Inference

Example request:

```
curl http://SERVER_IP:11434/api/generate \
-d '{
 "model": "llama3.2:1b",
 "prompt": "Hello"
}'
```

Example response:

```
Hello! How can I assist you today?
```

---

# Example Use Case

This inference node was used in a **document generation pipeline**.

Workflow:

```
Upload Excel dataset
↓
Parse dataset into sections
↓
Generate each section using LLM
↓
Combine into final report
```

Example dataset size:

```
69 sections
```

Processing is done sequentially to avoid context window limits.

---

# Monitor Live Logs

To see inference activity:

```
docker logs -f ollama-service
```

Example log entries:

```
POST /api/generate
POST /api/generate
POST /api/generate
```

---

# When CPU Inference Is Enough

CPU LLM inference works well for:

```
automation tools
report generation
document summarization
internal AI utilities
RAG pipelines
```

Small models (1B–3B) can run comfortably on standard VMs.

---

# Future Improvements

Possible upgrades for this setup:

Parallel generation workers

```
process multiple sections simultaneously
```

OpenAI-compatible API layer

```
LiteLLM
```

Model routing

```
small model → draft
larger model → refine
```

GPU upgrade

```
7B+ models
```

---

# License

MIT

