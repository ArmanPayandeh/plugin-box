#!/bin/bash

LOCALAI_DIR="/opt/localai"

echo "Uninstalling LocalAI..."

# Stop the service if running
if sudo docker ps | grep -q localai; then
    echo "Stopping LocalAI service..."
    cd $LOCALAI_DIR
    sudo docker-compose down
fi

# Remove containers and images
echo "Removing LocalAI containers and images..."
sudo docker rm -f localai 2>/dev/null
sudo docker rmi localai/localai:latest-aio-cpu 2>/dev/null

# Ask user about data removal
read -p "Do you want to remove all LocalAI data and modelsبر اساس بررسی ساختار پلاگین‌های موجود در مخزن GitHub که اشاره کردید و اطلاعاتی که از جستجو به دست آوردم، یک پلاگین کامل برای LocalAI می‌نویسم:

## ساختار پلاگین LocalAI

### 1. `install.sh`
```bash
#!/bin/bash

set -e

echo "Installing LocalAI..."

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. Please install Docker first."
    exit 1
fi

# Check if docker-compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "docker-compose is not installed. Installing..."
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
fi

# Create LocalAI directory
LOCALAI_DIR="$HOME/.localai"
mkdir -p "$LOCALAI_DIR/models"
mkdir -p "$LOCALAI_DIR/data"

# Create docker-compose.yml
cat > "$LOCALAI_DIR/docker-compose.yml" << 'EOF'
version: '3.8'

services:
  localai:
    image: localai/localai:latest
    container_name: localai
    restart: unless-stopped
    ports:
      - "0.0.0.0:8080:8080"
    volumes:
      - ./models:/models
      - ./data:/data
    environment:
      - THREADS=4
      - CONTEXT_SIZE=512
      - MODELS_PATH=/models
      - GALLERIES=[{"name":"model-gallery","url":"github:go-skynet/model-gallery/index.yaml"}]
    command: --address 0.0.0.0:8080
EOF

# Pull the LocalAI image
echo "Pulling LocalAI Docker image..."
docker pull localai/localai:latest

# Generate API key
API_KEY="sk-$(openssl rand -hex 16)"
echo "$API_KEY" > "$LOCALAI_DIR/.api_key"
chmod 600 "$LOCALAI_DIR/.api_key"

echo "LocalAI has been successfully installed!"
echo "Installation directory: $LOCALAI_DIR"
echo "API Key has been generated and saved to: $LOCALAI_DIR/.api_key"