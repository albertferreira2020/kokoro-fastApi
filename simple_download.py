#!/usr/bin/env python3
"""Simple model downloader without external dependencies."""

import json
import os
import urllib.request
import ssl
import sys

# Disable SSL verification for older Python versions
ssl._create_default_https_context = ssl._create_unverified_context

def download_file(url, filepath):
    """Download a file from URL to filepath."""
    print(f"Downloading {url}...")
    try:
        urllib.request.urlretrieve(url, filepath)
        print(f"✓ Downloaded {os.path.basename(filepath)}")
        return True
    except Exception as e:
        print(f"✗ Failed to download {url}: {e}")
        return False

def main():
    """Download Kokoro v1.0 model files."""
    output_dir = "api/src/models/v1_0"
    
    # Create output directory
    os.makedirs(output_dir, exist_ok=True)
    
    # Define file paths
    model_file = "kokoro-v1_0.pth"
    config_file = "config.json"
    model_path = os.path.join(output_dir, model_file)
    config_path = os.path.join(output_dir, config_file)
    
    # Check if files already exist
    if os.path.exists(model_path) and os.path.exists(config_path):
        print("Model files already exist")
        return
    
    # GitHub release URLs
    base_url = "https://github.com/remsky/Kokoro-FastAPI/releases/download/v0.1.4"
    model_url = f"{base_url}/{model_file}"
    config_url = f"{base_url}/{config_file}"
    
    # Download files
    print("Downloading Kokoro v1.0 model files...")
    
    success = True
    if not os.path.exists(model_path):
        success &= download_file(model_url, model_path)
    
    if not os.path.exists(config_path):
        success &= download_file(config_url, config_path)
    
    if success:
        print(f"✓ Model files ready in {output_dir}")
    else:
        print("✗ Failed to download some files")
        sys.exit(1)

if __name__ == "__main__":
    main()
