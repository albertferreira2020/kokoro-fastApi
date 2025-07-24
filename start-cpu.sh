#!/bin/bash

# Get project root directory
PROJECT_ROOT=$(pwd)

# Set environment variables
export USE_GPU=false
export USE_ONNX=false
export PYTHONPATH=$PROJECT_ROOT:$PROJECT_ROOT/api
export MODEL_DIR=src/models
export VOICES_DIR=src/voices/v1_0
export WEB_PLAYER_PATH=$PROJECT_ROOT/web
# Set the espeak-ng data path for Linux Ubuntu
export ESPEAK_DATA_PATH=/usr/lib/x86_64-linux-gnu/espeak-ng-data

# Run FastAPI with CPU extras using uv run
# Note: espeak may still require manual installation,
echo "Installing dependencies..."
uv pip install -e ".[cpu]"

# Make sure uvicorn is available
echo "Ensuring uvicorn is installed..."
uv pip install uvicorn

# Download model using the proper Python executable
if [ "$DOWNLOAD_MODEL" = "true" ] || [ ! -f "api/src/models/v1_0/kokoro-v1_0.pth" ]; then
    echo "Checking for download script..."
    # Check for the simple download script first, then the original one
    if [ -f "simple_download.py" ]; then
        echo "Found simple download script, downloading model files..."
        python3 simple_download.py
    elif [ -f "docker/scripts/download_model.py" ]; then
        echo "Found download script in container, downloading model files..."
        # Install loguru first for the original script
        uv pip install loguru
        uv run --no-sync python docker/scripts/download_model.py --output api/src/models/v1_0
    else
        echo "No download script found, attempting direct download..."
        # Fallback: create a simple download directly in the script
        mkdir -p api/src/models/v1_0
        echo "Downloading Kokoro model files directly..."
        python3 -c "
import urllib.request
import ssl
import os

ssl._create_default_https_context = ssl._create_unverified_context

base_url = 'https://github.com/remsky/Kokoro-FastAPI/releases/download/v0.1.4'
files = ['kokoro-v1_0.pth', 'config.json']

for file in files:
    url = f'{base_url}/{file}'
    filepath = f'api/src/models/v1_0/{file}'
    if not os.path.exists(filepath):
        print(f'Downloading {file}...')
        urllib.request.urlretrieve(url, filepath)
        print(f'✓ Downloaded {file}')
    else:
        print(f'✓ {file} already exists')
print('Model download complete!')
"
    fi
else
    echo "Model files already exist, skipping download"
fi

# Apply the misaki patch to fix possible EspeakWrapper issue in older versions
# echo "Applying misaki patch..."
# python scripts/fix_misaki.py

# Start the server
echo "Starting the FastAPI server..."
uv run uvicorn api.src.main:app --host 0.0.0.0 --port 8880
