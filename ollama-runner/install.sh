#!/bin/bash
set -e

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}Installing Ollama Service...${NC}"

# Create directories
echo -e "${YELLOW}Creating directories...${NC}"
sudo mkdir -p /data/ollama/models
sudo chmod -R 755 /data/ollama

# Install Ollama using official script
echo -e "${YELLOW}Installing Ollama using official installer...${NC}"
curl -fsSL https://ollama.com/install.sh | sh

# Create systemd override for custom configuration
echo -e "${YELLOW}Configuring Ollama service...${NC}"
sudo mkdir -p /etc/systemd/system/ollama.service.d/
cat << EOF | sudo tee /etc/systemd/system/ollama.service.d/override.conf
[Service]
Environment="OLLAMA_HOST=0.0.0.0"
Environment="OLLAMA_MODELS=/data/ollama/models"
Environment="OLLAMA_ORIGINS=*"
Environment="OLLAMA_CORS_ALLOW_ORIGINS=*"
EOF

# Reload systemd
sudo systemctl daemon-reload

echo -e "${GREEN}Ollama installation completed successfully!${NC}"
echo -e "${YELLOW}To start the service, run: ./start.sh${NC}"