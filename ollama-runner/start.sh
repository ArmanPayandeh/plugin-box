#!/bin/bash
set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}Starting Ollama service...${NC}"

# Check if service exists
if ! systemctl list-unit-files | grep -q ollama.service; then
    echo -e "${RED}Ollama service not found. Please run install.sh first.${NC}"
    exit 1
fi

# Start the service
sudo systemctl start ollama.service
sudo systemctl enable ollama.service

# Wait for service to be ready
echo -e "${YELLOW}Waiting for Ollama to be ready...${NC}"
for i in {1..30}; do
    if curl -s http://localhost:11434/api/version >/dev/null 2>&1; then
        echo -e "${GREEN}Ollama service started successfully!${NC}"
        break
    fi
    sleep 1
done

# Show service status
sudo systemctl status ollama.service --no-pager

# Show API endpoint
echo -e ""
echo -e "${GREEN}Ollama API available at: http://localhost:11434${NC}"
echo -e "${YELLOW}To pull a model, run: ollama pull llama2${NC}"