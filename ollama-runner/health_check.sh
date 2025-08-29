#!/bin/bash

# Health check script for monitoring
check_ollama_health() {
    # Check if service is running
    if ! systemctl is-active --quiet ollama.service; then
        echo "ERROR: Ollama service is not running"
        exit 1
    fi
    
    # Check API endpoint
    if ! curl -s http://localhost:11434/api/version >/dev/null 2>&1; then
        echo "ERROR: Ollama API is not responding"
        exit 1
    fi
    
    # Check GPU utilization if available
    if command -v nvidia-smi &> /dev/null; then
        GPU_UTIL=$(nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits | head -1)
        echo "GPU Utilization: ${GPU_UTIL}%"
    fi
    
    # Check memory usage
    MEMORY=$(ps aux | grep ollama | grep -v grep | awk '{print $4}' | head -1)
    echo "Memory Usage: ${MEMORY}%"
    
    echo "OK: Ollama is healthy"
    exit 0
}

check_ollama_health