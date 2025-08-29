#!/bin/bash
set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${YELLOW}Starting Ollama service...${NC}"

# Check and fix permissions first
echo -e "${YELLOW}Checking permissions...${NC}"
if [ ! -w /data/ollama/models ]; then
 echo -e "${YELLOW}Fixing permissions...${NC}"
 sudo mkdir -p /data/ollama/models
 sudo chown -R ollama:ollama /data/ollama
 sudo chmod -R 755 /data/ollama
fi

# Start the service
sudo systemctl start ollama
sudo systemctl enable ollama

# Wait for service to be ready
echo -e "${YELLOW}Waiting for Ollama to be ready...${NC}"
for i in {1..30}; do
 if curl -s http://localhost:11434/api/version >/dev/null 2>&1; then
 echo -e "${GREEN}Ollama service started successfully!${NC}"
 break
 fi
 sleep 1
 echo -n "."
done

# Check if it's listening on 0.0.0.0
echo -e "\n${YELLOW}Checking network binding...${NC}"
BINDING=$(sudo netstat -tlnp | grep 11434 | awk '{print $4}')
if [[ "$BINDING" == *"0.0.0.0:11434"* ]]; then
 echo -e "${GREEN}✓ Ollama is listening on all interfaces${NC}"
else
 echo -e "${RED}✗ Ollama is not bound to 0.0.0.0${NC}"
 echo -e "${YELLOW}Current binding: $BINDING${NC}"
 echo -e "${YELLOW}Restarting service...${NC}"
 sudo systemctl restart ollama
 sleep 3
fi

# Get server IP addresses
echo -e "\n${BLUE}=== Server Access Information ===${NC}"
echo -e "\n${GREEN}Available endpoints:${NC}"

# Local access
echo -e "${YELLOW}Local:${NC} http://localhost:11434"

# Get all IP addresses
for ip in $(hostname -I); do
 echo -e "${YELLOW}Network:${NC} http://$ip:11434"
done

# Get public IP
PUBLIC_IP=$(curl -s -4 ifconfig.me 2>/dev/null || echo "")
if [ ! -z "$PUBLIC_IP" ]; then
 echo -e "${YELLOW}Public:${NC} http://$PUBLIC_IP:11434"
 MAIN_URL="http://$PUBLIC_IP:11434"
else
 FIRST_IP=$(hostname -I | awk '{print $1}')
 MAIN_URL="http://$FIRST_IP:11434"
fi

# Test connectivity
echo -e "\n${BLUE}=== Testing Connectivity ===${NC}"
if curl -s http://localhost:11434/api/version >/dev/null 2>&1; then
 echo -e "${GREEN}✓ Local connection OK${NC}"
 VERSION=$(curl -s http://localhost:11434/api/version | jq -r .version)
 echo -e "${GREEN} Ollama version: $VERSION${NC}"
else
 echo -e "${RED}✗ Local connection failed${NC}"
fi

# Test external access
FIRST_IP=$(hostname -I | awk '{print $1}')
if curl -s --connect-timeout 5 http://$FIRST_IP:11434/api/version >/dev/null 2>&1; then
 echo -e "${GREEN}✓ External access working${NC}"
else
 echo -e "${RED}✗ External access not working - check firewall${NC}"
fi

# Generate QR code
echo -e "\n${BLUE}=== QR Code for API Access ===${NC}"
echo -e "${YELLOW}Scan this QR code to access Ollama API:${NC}\n"
qrencode -t ANSIUTF8 "$MAIN_URL"
echo -e "\n${GREEN}URL: $MAIN_URL${NC}"

# Show API usage examples
echo -e "\n${BLUE}=== Quick Start Guide ===${NC}"
echo -e "${YELLOW}1. Test the API:${NC}"
echo -e " curl $MAIN_URL/api/version"
echo -e "\n${YELLOW}2. Pull a model:${NC}"
echo -e " ollama pull llama2"
echo -e "\n${YELLOW}3. Generate text:${NC}"
echo -e " curl $MAIN_URL/api/generate -d '{\"model\": \"llama2\", \"prompt\": \"Hello!\"}'"

# Show service status
echo -e "\n${BLUE}=== Service Status ===${NC}"
sudo systemctl status ollama --no-pager | head -n 15

# Save connection info
sudo mkdir -p /opt/ollama
echo "Ollama API Endpoints:" | sudo tee /opt/ollama/connection-info.txt >/dev/null
echo "Local: http://localhost:11434" | sudo tee -a /opt/ollama/connection-info.txt >/dev/null
echo "Network: $MAIN_URL" | sudo tee -a /opt/ollama/connection-info.txt >/dev/null
echo -e "\n${YELLOW}Connection info saved to: /opt/ollama/connection-info.txt${NC}"