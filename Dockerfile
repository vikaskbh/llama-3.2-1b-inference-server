FROM ollama/ollama:latest

# Pre-loading the 1B model so the "live" VM doesn't struggle later
RUN nohup bash -c "ollama serve &" && \
    sleep 5 && \
    ollama pull llama3.2:1b && \
    pkill ollama

EXPOSE 11434
ENTRYPOINT ["ollama", "serve"]
