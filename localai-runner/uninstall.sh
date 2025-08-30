#!/bin/bash

set -e

LOCALAI_DIR="$HOME/.localai"

echo "Uninstalling LocalAI..."

# Stop the service if running
if docker ps | grep -q localai; then
    echo "Stopping LocalAI service..."
    cd "$LOCALAI_DIR"
    docker-compose down
fi

# Remove container
if docker ps -a | grep -q localai; then
    echo "Removing LocalAI container..."
    docker rm -f localai 2>/dev/null || true
fi

# Remove image
if docker images | grep -q "localai/localai"; then
    read -p "Do you want to remove LocalAI Docker image? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Removing LocalAI Docker image..."
        docker rmi localai/localai:latest-aio-cpu
    fi
fi

# Ask about data removal
if [ -d "$LOCALAI_DIR" ]; then
    echo ""
    echo "LocalAI data directory: $LOCALAI_DIR"
    read -p "Do you want to remove all LocalAI data and models? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Removing LocalAI data directory..."
        rm -rf "$LOCALAI_DIR"
        echo "All LocalAI data has been removed."
    else
        echo "LocalAI data preserved at: $LOCALAI_DIR"
        echo "You can manually remove it later with: rm -rf $LOCALAI_DIR"
    fi
fi

echo "LocalAI has been uninstalled!"