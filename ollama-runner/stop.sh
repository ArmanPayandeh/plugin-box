#!/bin/bash
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}Stopping Ollama service...${NC}"

sudo systemctl stop ollama

echo -e "${GREEN}Ollama service stopped.${NC}"