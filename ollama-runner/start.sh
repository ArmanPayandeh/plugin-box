#!/bin/bash
set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${YELLOW}Starting Ollama service...${NC}"

# Start and enable the service
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

# Get server IP addresses
echo -e "\n${BLUE}=== Server Access Information ===${NC}"

# Get all network interfaces IPs
echo -e "${GREEN}Available endpoints:${NC}"
echo -e "${YELLOW}Local:${NC} http://localhost:11434"

# Get all IP addresses
for ip in $(hostname -I); do
    echo -e "${YELLOW}Network:${NC} http://${ip}:11434"
done

# Get public IP (if available)
PUBLIC_IP=$(curl -s -4 ifconfig.me 2>/dev/null || echo "")
if [ ! -z "$PUBLIC_IP" ]; then
    echo -e "${YELLOW}Public:${NC} http://${PUBLIC_IP}:11434"
    MAIN_URL="http://${PUBLIC_IP}:11434"
else
    # Use first local IP if no public IP
    FIRST_IP=$(hostname -I | awk '{print $1}')
    MAIN_URL="http://${FIRST_IP}:11434"
fi

# Install qrencode if not present
if ! command -v qrencode &> /dev/null; then
    echo -e "\n${YELLOW}Installing qrencode for QR code generation...${NC}"
    sudo apt-get update -qq
    sudo apt-get install -y qrencode
fi

# Generate QR code
echo -e "\n${BLUE}=== QR Code for Mobile Access ===${NC}"
echo -e "${YELLOW}Scan this QR code to access Ollama API:${NC}\n"
qrencode -t UTF8 "$MAIN_URL"
echo -e "\n${GREEN}URL: $MAIN_URL${NC}"

# Show service status
echo -e "\n${BLUE}=== Service Status ===${NC}"
sudo systemctl status ollama --no-pager | head -n 10

# Show usage examples
echo -e "\n${BLUE}=== Quick Start Guide ===${NC}"
echo -e "${YELLOW}1. Pull a model:${NC}"
echo -e "   ollama pull llama2:7b"
echo -e "\n${YELLOW}2. Test the API:${NC}"
echo -e "   curl ${MAIN_URL}/api/version"
echo -e "\n${YELLOW}3. Generate text:${NC}"
echo -e "   curl ${MAIN_URL}/api/generate -d '{"
echo -e "     \"model\": \"llama2:7b\","
echo -e "     \"prompt\": \"Hello, how are you?\""
echo -e "   }'"
echo -e "\n${GREEN}Ollama is ready to use!${NC}"