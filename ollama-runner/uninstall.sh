#!/bin/bash
set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}Uninstalling Ollama service...${NC}"

# Confirmation prompt
read -p "Are you sure you want to uninstall Ollama? This will remove all models and data. (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Uninstall cancelled.${NC}"
    exit 0
fi

# Stop service if running
if systemctl is-active --quiet ollama.service; then
    echo -e "${YELLOW}Stopping Ollama service...${NC}"
    sudo systemctl stop ollama.service
fi

# Disable service
if systemctl list-unit-files | grep -q ollama.service; then
    sudo systemctl disable ollama.service
    sudo rm -f /etc/systemd/system/ollama.service
    sudo systemctl daemon-reload
fi

# Remove Ollama binary
if [ -f /usr/local/bin/ollama ]; then
    sudo rm -f /usr/local/bin/ollama
fi

# Remove directories
echo -e "${YELLOW}Removing Ollama directories...${NC}"
sudo rm -rf /opt/ollama

# Ask about model data
read -p "Do you want to remove all downloaded models? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo rm -rf /data/ollama
    echo -e "${YELLOW}Models removed.${NC}"
else
    echo -e "${YELLOW}Models preserved in /data/ollama${NC}"
fi

echo -e "${GREEN}Ollama uninstalled successfully!${NC}"