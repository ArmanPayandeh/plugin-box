#!/bin/bash
set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}Installing Ollama Service...${NC}"

# Install dependencies
echo -e "${YELLOW}Installing dependencies...${NC}"
sudo apt-get update -qq
sudo apt-get install -y curl jq qrencode net-tools

# Create directories first
echo -e "${YELLOW}Creating directories...${NC}"
sudo mkdir -p /data/ollama/models
sudo chmod -R 755 /data/ollama

# Install Ollama
echo -e "${YELLOW}Installing Ollama...${NC}"
curl -fsSL https://ollama.com/install.sh | sh

# Wait a moment for service to be created
sleep 2

# Stop the service to modify configuration
echo -e "${YELLOW}Configuring Ollama...${NC}"
sudo systemctl stop ollama

# Backup original service file
sudo cp /etc/systemd/system/ollama.service /etc/systemd/system/ollama.service.backup

# Modify the service file to add OLLAMA_HOST
sudo sed -i '/\[Service\]/a Environment="OLLAMA_HOST=0.0.0.0"\nEnvironment="OLLAMA_MODELS=/data/ollama/models"' /etc/systemd/system/ollama.service

# Also create override directory for extra safety
sudo mkdir -p /etc/systemd/system/ollama.service.d
cat << EOF | sudo tee /etc/systemd/system/ollama.service.d/override.conf
[Service]
Environment="OLLAMA_HOST=0.0.0.0"
Environment="OLLAMA_MODELS=/data/ollama/models"
Environment="OLLAMA_ORIGINS=*"
EOF

# Create environment file
sudo mkdir -p /etc/default
cat << EOF | sudo tee /etc/default/ollama
OLLAMA_HOST=0.0.0.0
OLLAMA_MODELS=/data/ollama/models
EOF

# Reload systemd
sudo systemctl daemon-reload

echo -e "${GREEN}Ollama installation completed!${NC}"
echo -e "${YELLOW}Configuration set to bind to 0.0.0.0:11434${NC}"
echo -e "${YELLOW}To start the service, run: ./start.sh${NC}"