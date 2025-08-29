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

# Stop and disable service
echo -e "${YELLOW}Stopping and disabling service...${NC}"
sudo systemctl stop ollama 2>/dev/null || true
sudo systemctl disable ollama 2>/dev/null || true

# Remove Ollama binary and service files
echo -e "${YELLOW}Removing Ollama files...${NC}"
sudo rm -f /usr/local/bin/ollama
sudo rm -f /etc/systemd/system/ollama.service
sudo rm -rf /etc/systemd/system/ollama.service.d
sudo rm -rf /opt/ollama

# Remove user
sudo userdel -r ollama 2>/dev/null || true

# Ask about model data
read -p "Do you want to remove all downloaded models? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
 echo -e "${YELLOW}Removing model data...${NC}"
 sudo rm -rf /data/ollama
 sudo rm -rf /usr/share/ollama
 echo -e "${YELLOW}Models removed.${NC}"
else
 echo -e "${YELLOW}Models preserved in /data/ollama${NC}"
fi

# Reload systemd
sudo systemctl daemon-reload

echo -e "${GREEN}Ollama uninstalled successfully!${NC}"