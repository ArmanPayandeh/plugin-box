#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}Installing Ollama Service...${NC}"

# Install dependencies
echo -e "${YELLOW}Installing dependencies...${NC}"
sudo apt-get update -qq
sudo apt-get install -y curl jq qrencode net-tools

# Install Ollama using official script
echo -e "${YELLOW}Installing Ollama...${NC}"
curl -fsSL https://ollama.com/install.sh | sh

# Wait for installation to complete
sleep 2

# Create directories with correct permissions
echo -e "${YELLOW}Creating directories with proper permissions...${NC}"
sudo mkdir -p /data/ollama/models
sudo chown -R ollama:ollama /data/ollama
sudo chmod -R 755 /data/ollama

# Stop the service to modify configuration
echo -e "${YELLOW}Configuring Ollama...${NC}"
sudo systemctl stop ollama

# Create override configuration for 0.0.0.0 binding
sudo mkdir -p /etc/systemd/system/ollama.service.d
cat << EOF | sudo tee /etc/systemd/system/ollama.service.d/override.conf
[Service]
Environment="OLLAMA_HOST=0.0.0.0"
Environment="OLLAMA_MODELS=/data/ollama/models"
Environment="OLLAMA_ORIGINS=*"
EOF

# Ensure permissions are correct after configuration
sudo chown -R ollama:ollama /data/ollama
sudo chmod -R 755 /data/ollama

# Reload systemd and start service
sudo systemctl daemon-reload
sudo systemctl start ollama
sudo systemctl enable ollama

# Wait for service to start
sleep 3

# Verify permissions and service status
if sudo systemctl is-active --quiet ollama; then
 echo -e "${GREEN}✓ Ollama service is running${NC}"
else
 echo -e "${YELLOW}⚠ Service might need a moment to start...${NC}"
fi

echo -e "${GREEN}Ollama installation completed successfully!${NC}"
echo -e "${YELLOW}Configuration set to bind to 0.0.0.0:11434${NC}"
echo -e "${YELLOW}To start/verify the service, run: ./start.sh${NC}"