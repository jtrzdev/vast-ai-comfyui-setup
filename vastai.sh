#!/bin/bash

set -e  # Exit on error

echo "🚀 Starting ComfyUI installation and model downloads..."

# Define base directories
BASE_DIR="/workspace"
MODELS_DIR="$BASE_DIR/ComfyUI/models"
LORA_DIR="$MODELS_DIR/loras"
CHECKPOINT_DIR="$MODELS_DIR/checkpoints"
ULTRALYTICS_DIR="$MODELS_DIR/ultralytics/segm"

# Install ComfyUI if not installed
if [ ! -d "$BASE_DIR/ComfyUI" ]; then
    echo "📥 Cloning ComfyUI..."
    git clone https://github.com/comfyanonymous/ComfyUI.git "$BASE_DIR"
else
    echo "✅ ComfyUI already installed."
fi

# Install ComfyUI-Manager if not installed
if [ ! -d "$BASE_DIR/ComfyUI/custom_nodes/ComfyUI-Manager" ]; then
    echo "📥 Cloning ComfyUI-Manager..."
    git clone https://github.com/ltdrdata/ComfyUI-Manager.git "$BASE_DIR/ComfyUI/custom_nodes"
else
    echo "✅ ComfyUI-Manager already installed."
fi

# Create necessary directories after ComfyUI is cloned
mkdir -p "$LORA_DIR/characters" "$LORA_DIR/styles" "$CHECKPOINT_DIR" "$ULTRALYTICS_DIR"

# Function to download files if they don't exist
download_model() {
    local url=$1
    local folder=$2
    local filename=$(basename $(wget --content-disposition --quiet --spider --server-response "$url" 2>&1 | awk '/Content-Disposition/ {print $NF}'))
    
    if [ ! -f "$folder/$filename" ]; then
        echo "⬇️ Downloading: $filename to $folder"
        wget --content-disposition -P "$folder" "$url"
    else
        echo "✅ Already exists: $folder/$filename"
    fi
}

# Download models
echo "📥 Downloading Character LoRAs..."
download_model "https://civitai.com/api/download/models/1453689?token=b3351d12861914cf2757bce4b93f33fe" "$LORA_DIR/characters"
download_model "https://civitai.com/api/download/models/1451050?token=b3351d12861914cf2757bce4b93f33fe" "$LORA_DIR/characters"
download_model "https://civitai.com/api/download/models/1245593?token=b3351d12861914cf2757bce4b93f33fe" "$LORA_DIR/characters"
download_model "https://civitai.com/api/download/models/1593973?token=b3351d12861914cf2757bce4b93f33fe" "$LORA_DIR/characters"
download_model "https://civitai.com/api/download/models/1593945?token=b3351d12861914cf2757bce4b93f33fe" "$LORA_DIR/characters"
download_model "https://civitai.com/api/download/models/1593987?token=b3351d12861914cf2757bce4b93f33fe" "$LORA_DIR/characters"
download_model "https://civitai.com/api/download/models/1594005?token=b3351d12861914cf2757bce4b93f33fe" "$LORA_DIR/characters"
download_model "https://civitai.com/api/download/models/1593929?token=b3351d12861914cf2757bce4b93f33fe" "$LORA_DIR/characters"
download_model "https://civitai.com/api/download/models/1372788?token=b3351d12861914cf2757bce4b93f33fe" "$LORA_DIR/characters"
download_model "https://civitai.com/api/download/models/1247539?token=b3351d12861914cf2757bce4b93f33fe" "$LORA_DIR/characters"
download_model "https://civitai.com/api/download/models/1098813?token=b3351d12861914cf2757bce4b93f33fe" "$LORA_DIR/characters"

echo "📥 Downloading Style LoRAs..."
download_model "https://civitai.com/api/download/models/1570070?token=b3351d12861914cf2757bce4b93f33fe" "$LORA_DIR/styles"
download_model "https://civitai.com/api/download/models/1067949?token=b3351d12861914cf2757bce4b93f33fe" "$LORA_DIR/styles"

echo "📥 Downloading Checkpoints..."
download_model "https://civitai.com/api/download/models/1379960?token=b3351d12861914cf2757bce4b93f33fe" "$CHECKPOINT_DIR"

echo "📥 Downloading ADetailer Model..."
download_model "https://civitai.com/api/download/models/465360?token=b3351d12861914cf2757bce4b93f33fe" "$ULTRALYTICS_DIR"

echo "✅ Setup complete: ComfyUI, ComfyUI-Manager, and model downloads finished."
