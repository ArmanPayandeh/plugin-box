#!/bin/bash

set -e

LOCALAI_DIR="$HOME/.localai"
PORT=8080

# Check if LocalAI is already running
if docker ps | grep -q localai; then
    echo "LocalAI is already running!"
    # Get host IP
    HOST_IP=$(hostname -I | awk '{print $1}')
    # Read API key
    API_KEY=$(cat "$LOCALAI_DIR/.api_key" 2>/dev/null || echo "No API key found")
    
    echo "================================"
    echo "LocalAI Service Status: RUNNING"
    echo "================================"
    echo "Access URL: http://0.0.0.0:$PORT"
    echo "Local URL: http://localhost:$PORT"
    echo "Network URL: http://$HOST_IP:$PORT"
    echo "API Key: $API_KEY"
    echo "================================"
    exit 0
fi

# Check if installation exists
if [ ! -f "$LOCALAI_DIR/docker-compose.yml" ]; then
    echo "Error: LocalAI is not installed. Please run install.sh first."
    exit 1
fi

# Start LocalAI
echo "Starting LocalAI service..."
cd "$LOCALAI_DIR"
docker-compose up -d

# Wait for service to be ready
echo "Waiting for LocalAI to start..."
for i in {1..30}; do
    if curl -s http://localhost:$PORT/healthz > /dev/null 2>&1; then
        break
    fi
    sleep 1
done

# Check if service started successfully
if docker ps | grep -q localai; then
    # Get host IP
    HOST_IP=$(hostname -I | awk '{print $1}')
    # Read API key
    API_KEY=$(cat "$LOCALAI_DIR/.api_key")
    
    echo ""
    echo "================================"
    echo "LocalAI started successfully!"
    echo "================================"
    echo "Access URL: http://0.0.0.0:$PORT"
    echo "Local URL: http://localhost:$PORT"
    echo "Network URL: http://$HOST_IP:$PORT"
    echo "API Key: $API_KEY"
    echo "================================"
    echo ""
    echo "API Endpoints:"
    echo "  - Health: http://$HOST_IP:$PORT/healthz"
    echo "  - Models: http://$HOST_IP:$PORT/v1/models"
    echo "  - Chat: http://$HOST_IP:$PORT/v1/chat/completions"
    echo "  - Completions: http://$HOST_IP:$PORT/v1/completions"
    echo "  - Embeddings: http://$HOST_IP:$PORT/v1/embeddings"
    echo ""
    echo "Test with curl:"
    echo "curl -H \"Authorization: Bearer $API_KEY\" http://localhost:$PORT/v1/models"
    echo ""
    
    # Save connection info
    cat > "$LOCALAI_DIR/.connection_info" << EOF
LocalAI Connection Information
==============================
Access URL: http://0.0.0.0:$PORT
Local URL: http://localhost:$PORT
Network URL: http://$HOST_IP:$PORT
API Key: $API_KEY
Started: $(date)
EOF
    
else
    echo "Error: Failed to start LocalAI service!"
    docker-compose logs localai
    exit 1
fi