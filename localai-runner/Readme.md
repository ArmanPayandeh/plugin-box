# LocalAI Plugin Installation and User Guide

## 📋 Table of Contents
- [Overview](#overview)
- [System Requirements](#system-requirements)
- [Pre-Installation Setup](#pre-installation-setup)
- [Installation Process](#installation-process)
- [Using LocalAI](#using-localai)
- [Management Commands](#management-commands)
- [Troubleshooting](#troubleshooting)
- [FAQ](#faq)
- [Support](#support)

## 🎯 Overview

LocalAI is a powerful plugin that allows you to run AI models locally on your system without relying on cloud services. This plugin automatically detects your hardware (CPU/GPU) and optimizes itself for the best performance.

### What LocalAI Does:
- ✅ Runs AI models locally (no internet required for inference)
- ✅ Automatically detects and uses your GPU if available
- ✅ Provides OpenAI-compatible API endpoints
- ✅ Web interface for easy interaction
- ✅ Supports various AI models (text generation, chat, etc.)

### Benefits:
- 🔒 **Privacy**: Your data never leaves your system
- ⚡ **Speed**: No network latency
- 💰 **Cost-effective**: No API fees
- 🛠️ **Customizable**: Use your own models

## 💻 System Requirements

### Minimum Requirements:
- **Operating System**: Ubuntu 18.04+ or Debian 10+
- **RAM**: 4GB (8GB recommended)
- **Storage**: 10GB free space
- **CPU**: x86_64 or ARM64 architecture
- **Network**: Internet connection for initial setup

### Recommended for Better Performance:
- **RAM**: 16GB or more
- **GPU**: NVIDIA GTX 1060+ or AMD RX 580+ or Intel Arc
- **Storage**: SSD with 50GB+ free space
- **CPU**: 8+ cores

### GPU Support:
- ✅ **NVIDIA**: GTX 10xx series or newer (with CUDA)
- ✅ **AMD**: RX 5xx series or newer (with ROCm)
- ✅ **Intel**: Arc series or newer
- ✅ **CPU-only**: Works without GPU (slower performance)

## 🛠️ Pre-Installation Setup

### Step 1: Update Your System
```bash
sudo apt update && sudo apt upgrade -y
```

### Step 2: Check System Information
```bash
# Check CPU information
lscpu

# Check memory
free -h

# Check available disk space
df -h

# Check for NVIDIA GPU (if applicable)
nvidia-smi

# Check for AMD GPU (if applicable)
lspci | grep -i amd
```

### Step 3: Ensure You Have Root Access
```bash
sudo whoami
# Should return: root
```

## 📦 Installation Process

### Step 1: Download the Plugin
```bash
# Navigate to your plugins directory
cd /path/to/your/plugins/directory

# Clone or download the LocalAI plugin
# (Replace with actual download method)
wget https://github.com/your-repo/localai-plugin.zip
unzip localai-plugin.zip
cd localai/
```

### Step 2: Make Installation Script Executable
```bash
chmod +x install.sh
```

### Step 3: Run Installation
```bash
sudo ./install.sh
```

**What happens during installation:**
1. 🔍 System hardware detection
2. 📦 Installing required dependencies (Docker, etc.)
3. 🏗️ Setting up directories and configuration
4. 🐳 Downloading LocalAI Docker image
5. ⚙️ Creating optimized configuration for your hardware
6. 🚀 Setting up system service
7. 📥 Downloading initial AI model

### Installation Output Example:
```
[2024-08-29 10:30:15] Starting LocalAI plugin installation...
[2024-08-29 10:30:16] Detecting hardware capabilities...
[2024-08-29 10:30:16] System Info:
[2024-08-29 10:30:16]  CPU Cores: 8
[2024-08-29 10:30:16]  Architecture: x86_64
[2024-08-29 10:30:16]  Memory: 16GB
[2024-08-29 10:30:17]  NVIDIA GPU detected: 1 card(s)
[2024-08-29 10:30:17] Installing dependencies...
[2024-08-29 10:30:45] Installation completed successfully!
```

## 🚀 Using LocalAI

### Starting LocalAI

#### Method 1: Using the Start Script
```bash
sudo ./start.sh
```

#### Method 2: Using System Service
```bash
sudo systemctl start localai.service
```

#### Method 3: Using Convenience Command
```bash
sudo localai-start
```

### Accessing LocalAI

Once started, LocalAI will be available at:
- **Web Interface**: http://localhost:8080
- **API Endpoint**: http://localhost:8080/v1

### First Time Setup

1. **Open your web browser**
2. **Navigate to**: http://localhost:8080
3. **You should see the LocalAI interface**

### Testing Your Installation

#### Test via Web Interface:
1. Go to http://localhost:8080
2. Try sending a simple message like "Hello, how are you?"
3. You should receive a response from the AI

#### Test via Command Line:
```bash
curl -X POST http://localhost:8080/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{
    "model": "gpt-3.5-turbo",
    "messages": [{"role": "user", "content": "Hello!"}]
  }'
```

### Using Different Models

LocalAI comes with a default model, but you can add more:

1. **Download models** to `/opt/localai/models/`
2. **Update configuration** in `/opt/localai/config/localai-config.yaml`
3. **Restart LocalAI** to load new models

Popular model sources:
- [Hugging Face](https://huggingface.co/models)
- [GPT4All](https://gpt4all.io/index.html)
- [TheBloke's Models](https://huggingface.co/TheBloke)

## 🎮 Management Commands

### Starting LocalAI
```bash
# Standard start
sudo ./start.sh

# Start and show status
sudo ./start.sh --status

# Start with health check
sudo ./start.sh --health
```

### Stopping LocalAI
```bash
# Graceful stop
sudo ./stop.sh

# Force stop
sudo ./stop.sh --force

# Stop and cleanup
sudo ./stop.sh --cleanup
```

### Checking Status
```bash
# Check service status
sudo systemctl status localai.service

# Check using start script
sudo ./start.sh --status

# Detailed health check
sudo /opt/localai/utils/health-check.sh
```

### Viewing Logs
```bash
# View service logs
sudo journalctl -u localai.service -f

# View container logs
sudo docker logs localai -f

# View log files
sudo tail -f /var/log/localai/localai.log
```

### Restarting LocalAI
```bash
# Restart service
sudo systemctl restart localai.service

# Or manually
sudo ./stop.sh
sudo ./start.sh
```

## 🔧 Troubleshooting

### Common Issues and Solutions

#### 1. LocalAI Won't Start

**Symptoms**: Service fails to start, containers don't run

**Solutions**:
```bash
# Check if Docker is running
sudo systemctl status docker
sudo systemctl start docker

# Check for port conflicts
sudo netstat -tuln | grep 8080

# Check system resources
free -h
df -h

# View detailed logs
sudo journalctl -u localai.service -n 50
```

#### 2. Poor Performance / Slow Responses

**Symptoms**: AI responses take very long

**Solutions**:
```bash
# Check if GPU is being used
nvidia-smi  # For NVIDIA
rocm-smi    # For AMD

# Check system resources
htop
sudo docker stats localai

# Verify configuration
cat /opt/localai/config/localai-config.yaml
```

#### 3. Out of Memory Errors

**Symptoms**: Container crashes, OOM errors in logs

**Solutions**:
```bash
# Check available memory
free -h

# Reduce model size or switch to smaller model
# Edit /opt/localai/config/localai-config.yaml

# Increase swap space
sudo fallocate -l 4G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

#### 4. GPU Not Detected

**Symptoms**: LocalAI uses CPU despite having GPU

**For NVIDIA**:
```bash
# Install NVIDIA drivers
sudo apt install nvidia-driver-525

# Install NVIDIA Container Toolkit
sudo apt install nvidia-docker2
sudo systemctl restart docker

# Test GPU access
sudo docker run --rm --gpus all nvidia/cuda:11.0-base nvidia-smi
```

**For AMD**:
```bash
# Install ROCm
sudo apt install rocm-dev rocm-libs

# Verify ROCm installation
rocm-smi
```

#### 5. Permission Errors

**Symptoms**: Permission denied errors

**Solutions**:
```bash
# Fix ownership
sudo chown -R root:root /opt/localai
sudo chmod -R 755 /opt/localai

# Add user to docker group (if needed)
sudo usermod -aG docker $USER
newgrp docker
```

### Diagnostic Commands

```bash
# Complete system check
sudo /opt/localai/utils/hardware-detect.sh
sudo /opt/localai/utils/health-check.sh --logs

# Check all services
sudo systemctl status docker localai.service

# Check container status
sudo docker ps -a
sudo docker images

# Check network connectivity
curl -I http://localhost:8080
```

## ❓ FAQ

### Q: How much disk space does LocalAI need?
**A**: Minimum 10GB, but models can be large. A typical setup needs 20-50GB.

### Q: Can I use LocalAI without a GPU?
**A**: Yes! It will work with CPU-only, but responses will be slower.

### Q: How do I add new AI models?
**A**: 
1. Download model files to `/opt/localai/models/`
2. Update `/opt/localai/config/localai-config.yaml`
3. Restart LocalAI

### Q: Is my data private?
**A**: Yes! Everything runs locally. No data is sent to external servers.

### Q: Can I access LocalAI from other computers?
**A**: By default, it's only accessible locally. You can modify the configuration to allow external access, but be careful about security.

### Q: How do I update LocalAI?
**A**: 
```bash
sudo docker pull quay.io/go-skynet/local-ai:latest
sudo ./stop.sh
sudo ./start.sh
```

### Q: How do I completely remove LocalAI?
**A**: 
```bash
sudo ./uninstall.sh
```

### Q: What models are supported?
**A**: LocalAI supports various formats including GGML, GGUF, and others. Popular models include GPT4All, Llama, Mistral, and more.

## 📞 Support

### Getting Help

1. **Check Logs First**:
   ```bash
   sudo /opt/localai/utils/health-check.sh --logs
   ```

2. **Common Log Locations**:
   - Service logs: `sudo journalctl -u localai.service`
   - Container logs: `sudo docker logs localai`
   - Application logs: `/var/log/localai/localai.log`

3. **Hardware Information**:
   ```bash
   sudo /opt/localai/utils/hardware-detect.sh
   ```

### Useful Resources

- **LocalAI Documentation**: https://localai.io/
- **Model Repository**: https://huggingface.co/models
- **Community Forum**: [Your community forum link]
- **GitHub Issues**: [Your GitHub issues link]

### Performance Optimization Tips

#### For GPU Users:
- Ensure latest GPU drivers are installed
- Use models optimized for your GPU memory
- Monitor GPU usage with `nvidia-smi` or `rocm-smi`

#### For CPU Users:
- Use quantized models (smaller file sizes)
- Adjust thread count in configuration
- Consider using swap space for large models

#### General Tips:
- Use SSD storage for better I/O performance
- Close unnecessary applications to free up RAM
- Monitor system resources during operation

---

## 🎉 Congratulations!

You now have LocalAI running on your system! You can:
- Chat with AI models privately
- Use the API for custom applications
- Experiment with different models
- Enjoy fast, local AI inference
