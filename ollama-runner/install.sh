#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}Installing Ollama Service...${NC}"

# Detect system architecture
ARCH=$(uname -m)
OS=$(uname -s | tr '[:upper:]' '[:lower:]')

# Detect GPU capabilities
detect_gpu() {
    echo -e "${YELLOW}Detecting GPU capabilities...${NC}"
    
    # Check for NVIDIA GPU
    if command -v nvidia-smi &> /dev/null; then
        echo -e "${GREEN}NVIDIA GPU detected${NC}"
        GPU_TYPE="nvidia"
        # Install NVIDIA Container Toolkit if not present
        if ! command -v nvidia-container-cli &> /dev/null; then
            echo -e "${YELLOW}Installing NVIDIA Container Toolkit...${NC}"
            curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
            curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
                sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
                sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
            sudo apt-get update
            sudo apt-get install -y nvidia-container-toolkit
            sudo nvidia-ctk runtime configure --runtime=docker
            sudo systemctl restart docker
        fi
    # Check for AMD GPU
    elif lspci | grep -i amd | grep -i vga &> /dev/null; then
        echo -e "${GREEN}AMD GPU detected${NC}"
        GPU_TYPE="amd"
    # Check for Intel GPU
    elif lspci | grep -i intel | grep -i vga &> /dev/null; then
        echo -e "${GREEN}Intel GPU detected${NC}"
        GPU_TYPE="intel"
    else
        echo -e "${YELLOW}No GPU detected, using CPU only${NC}"
        GPU_TYPE="cpu"
    fi
}

# Detect CPU capabilities
detect_cpu() {
    echo -e "${YELLOW}Detecting CPU capabilities...${NC}"
    
    CPU_CORES=$(nproc)
    CPU_MODEL=$(lscpu | grep "Model name" | cut -d ':' -f2 | xargs)
    
    # Check for AVX support
    if grep -q avx /proc/cpuinfo; then
        echo -e "${GREEN}AVX support detected${NC}"
        AVX_SUPPORT="true"
    else
        echo -e "${YELLOW}No AVX support detected${NC}"
        AVX_SUPPORT="false"
    fi
    
    echo -e "CPU: ${CPU_MODEL}"
    echo -e "Cores: ${CPU_CORES}"
}

# Create necessary directories
create_directories() {
    echo -e "${YELLOW}Creating directories...${NC}"
    sudo mkdir -p /opt/ollama/{models,config,logs}
    sudo mkdir -p /data/ollama/models
    sudo chmod -R 755 /opt/ollama
    sudo chmod -R 755 /data/ollama
}

# Install Ollama binary
install_ollama() {
    echo -e "${YELLOW}Installing Ollama...${NC}"
    
    # Download appropriate version based on architecture
    case $ARCH in
        x86_64|amd64)
            OLLAMA_URL="https://ollama.ai/download/ollama-linux-amd64"
            ;;
        aarch64|arm64)
            OLLAMA_URL="https://ollama.ai/download/ollama-linux-arm64"
            ;;
        *)
            echo -e "${RED}Unsupported architecture: $ARCH${NC}"
            exit 1
            ;;
    esac
    
    # Download and install
    sudo curl -L $OLLAMA_URL -o /usr/local/bin/ollama
    sudo chmod +x /usr/local/bin/ollama
}

# Create systemd service
create_service() {
    echo -e "${YELLOW}Creating systemd service...${NC}"
    
    # Generate service file based on detected hardware
    cat << EOF | sudo tee /etc/systemd/system/ollama.service
[Unit]
Description=Ollama Service
After=network-online.target docker.service
Wants=network-online.target

[Service]
Type=simple
User=root
Group=root
ExecStart=/usr/local/bin/ollama serve
Restart=always
RestartSec=10
Environment="OLLAMA_HOST=0.0.0.0"
Environment="OLLAMA_MODELS=/data/ollama/models"
Environment="OLLAMA_NUM_PARALLEL=${CPU_CORES}"
EOF

    # Add GPU-specific environment variables
    if [ "$GPU_TYPE" = "nvidia" ]; then
        echo 'Environment="CUDA_VISIBLE_DEVICES=0"' | sudo tee -a /etc/systemd/system/ollama.service
        echo 'Environment="NVIDIA_VISIBLE_DEVICES=all"' | sudo tee -a /etc/systemd/system/ollama.service
        echo 'Environment="NVIDIA_DRIVER_CAPABILITIES=compute,utility"' | sudo tee -a /etc/systemd/system/ollama.service
    fi

    cat << EOF | sudo tee -a /etc/systemd/system/ollama.service

[Install]
WantedBy=multi-user.target
EOF

    sudo systemctl daemon-reload
}

# Create configuration file
create_config() {
    echo -e "${YELLOW}Creating configuration...${NC}"
    
    cat << EOF | sudo tee /opt/ollama/config/ollama.json
{
  "gpu_type": "$GPU_TYPE",
  "cpu_cores": $CPU_CORES,
  "avx_support": $AVX_SUPPORT,
  "models_path": "/data/ollama/models",
  "host": "0.0.0.0",
  "port": 11434,
  "max_loaded_models": 1,
  "num_parallel": $CPU_CORES
}
EOF
}

# Main installation
main() {
    detect_gpu
    detect_cpu
    create_directories
    install_ollama
    create_service
    create_config
    
    echo -e "${GREEN}Ollama installation completed successfully!${NC}"
    echo -e "${YELLOW}Hardware Configuration:${NC}"
    echo -e "  GPU: $GPU_TYPE"
    echo -e "  CPU Cores: $CPU_CORES"
    echo -e "  AVX Support: $AVX_SUPPORT"
    echo -e ""
    echo -e "${YELLOW}To start the service, run: ./start.sh${NC}"
}

main