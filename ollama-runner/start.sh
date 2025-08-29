#!/bin/bash
set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${YELLOW}Starting Ollama service...${NC}"

# Ensure configuration is correct
if ! grep -q "OLLAMA_HOST=0.0.0.0" /etc/systemd/system/ollama.service; then
    echo -e "${YELLOW}Fixing configuration...${NC}"
    ./fix-binding.sh
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
done

# Check actual binding
echo -e "\n${YELLOW}Checking network binding...${NC}"
BINDING=$(sudo netstat -tlnp 2>/dev/null | grep 11434 || sudo ss -tlnp 2>/dev/null | grep 11434)
echo "$BINDING"

if echo "$BINDING" | grep -q "0.0.0.0:11434"; then
    echo -e "${GREEN}✓ Ollama is correctly bound to 0.0.0.0:11434${NC}"
else
    echo -e "${RED}✗ Ollama is NOT bound to 0.0.0.0:11434${NC}"
    echo -e "${YELLOW}Running fix script...${NC}"
    ./fix-binding.sh
fi

# Get server IP addresses
echo -e "\n${BLUE}=== Server Access Information ===${NC}"
echo -e "\n${GREEN}Available endpoints:${NC}"

# Local
echo -e "${YELLOW}Local:${NC} http://localhost:11434"

# All IPs
for ip in $(hostname -I); do
    echo -e "${YELLOW}Network:${NC} http://$ip:11434"
done

# Public IP
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
echo -e "${YELLOW}Testing local connection...${NC}"
if curl -s http://localhost:11434/api/version >/dev/null 2>&1; then
    echo -e "${GREEN}✓ Local connection OK${NC}"
else
    echo -e "${RED}✗ Local connection failed${NC}"
fi

echo -e "${YELLOW}Testing network connection...${NC}"
FIRST_IP=$(hostname -I | awk '{print $1}')
if curl -s http://$FIRST_IP:11434/api/version >/dev/null 2>&1; then
    echo -e "${GREEN}✓ Network connection OK${NC}"
else
    echo -e "${RED}✗ Network connection failed - checking firewall...${NC}"
    echo -e "${YELLOW}You may need to open port 11434 in your firewall${NC}"
fi

# Generate QR code
echo -e "\n${BLUE}=== QR Code for API Access ===${NC}"
echo -e "${YELLOW}Scan this QR code to access Ollama API:${NC}\n"
qrencode -t ANSIUTF8 "$MAIN_URL"

# Show usage
echo -e "\n${BLUE}=== Quick Test Commands ===${NC}"
echo -e "${YELLOW}From this server:${NC}"
echo -e " curl http://localhost:11434/api/version"
echo -e "\n${YELLOW}From another machine:${NC}"
echo -e " curl $MAIN_URL/api/version"
echo -e "\n${YELLOW}Pull a model:${NC}"
echo -e " ollama pull llama2"

# Save info
echo -e "\n${YELLOW}Connection info saved to:${NC} /opt/ollama/connection-info.txt"
sudo mkdir -p /opt/ollama
echo "Ollama API Endpoints:" | sudo tee /opt/ollama/connection-info.txt
echo "Local: http://localhost:11434" | sudo tee -a /opt/ollama/connection-info.txt
echo "Network: $MAIN_URL" | sudo tee -a /opt/ollama/connection-info.txt