#!/bin/bash
set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}Stopping Ollama service...${NC}"

# Check if service exists
if ! systemctl list-unit-files | grep -q ollama.service; then
    echo -e "${RED}Ollama service not found.${NC}"
    exit 1
fi

# Stop the service
sudo systemctl stop ollama.service

# Wait for service to stop
for i in {1..10}; do
    if ! systemctl is-active --quiet ollama.service; then
        echo -e "${GREEN}Ollama service stopped successfully!${NC}"
        exit 0
    fi
    sleep 1
done

# Force kill if still running
if systemctl is-active --quiet ollama.service; then
    echo -e "${YELLOW}Force stopping Ollama...${NC}"
    sudo systemctl kill ollama.service
fi

echo -e "${GREEN}Ollama service stopped.${NC}"