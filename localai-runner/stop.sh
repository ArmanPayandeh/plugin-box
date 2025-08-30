#!/bin/bash

set -e

LOCALAI_DIR="$HOME/.localai"

echo "Stopping LocalAI service..."

if docker ps | grep -q localai; then
    cd "$LOCALAI_DIR"
    docker-compose down
    echo "LocalAI service stopped successfully!"
else
    echo "LocalAI service is not running."
fi