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
if [ ! -d "$BASE_DIR/ComfyUI/.git" ]; then
    echo "📥 Cloning ComfyUI..."
    git clone https://github.com/comfyanonymous/ComfyUI.git "$BASE_DIR/ComfyUI"
else
    echo "✅ ComfyUI already installed."
fi

# Install ComfyUI-Manager if not installed
if [ ! -d "$BASE_DIR/ComfyUI/custom_nodes/comfyui-manager/.git" ]; then
    echo "📥 Cloning ComfyUI-Manager..."
    git clone https://github.com/ltdrdata/ComfyUI-Manager.git "$BASE_DIR/ComfyUI/custom_nodes/comfyui-manager"
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
        wget --content-disposition -P "$folder" "$url" || { echo "❌ Failed to download: $filename"; exit 1; }
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

# Install dependencies for ComfyUI if not already installed
echo "📦 Installing dependencies..."
pip install -r "$BASE_DIR/ComfyUI/requirements.txt"

# Clone the necessary custom node repositories if not already cloned
echo "📥 Cloning additional custom nodes..."

if [ ! -d "$BASE_DIR/ComfyUI/custom_nodes/comfyui-impact-pact/.git" ]; then
    git clone https://github.com/ltdrdata/ComfyUI-Impact-Pack.git "$BASE_DIR/ComfyUI/custom_nodes/comfyui-impact-pact"
fi

if [ ! -d "$BASE_DIR/ComfyUI/custom_nodes/comfyui-impact-subpack/.git" ]; then
    git clone https://github.com/ltdrdata/ComfyUI-Impact-Subpack.git "$BASE_DIR/ComfyUI/custom_nodes/comfyui-impact-subpack"
fi

if [ ! -d "$BASE_DIR/ComfyUI/custom_nodes/comfyroll-studio/.git" ]; then
    git clone https://github.com/Suzie1/ComfyUI_Comfyroll_CustomNodes.git "$BASE_DIR/ComfyUI/custom_nodes/comfyroll-studio"
fi

if [ ! -d "$BASE_DIR/ComfyUI/custom_nodes/rgthree/.git" ]; then
    git clone https://github.com/rgthree/rgthree-comfy.git "$BASE_DIR/ComfyUI/custom_nodes/rgthree"
fi

# Install dependencies for the additional custom nodes (if any)
echo "📦 Installing dependencies for additional custom nodes..."
for repo in comfyui-impact-pact comfyui-impact-subpack rgthree; do
    if [ -f "$BASE_DIR/ComfyUI/custom_nodes/$repo/requirements.txt" ]; then
        pip install -r "$BASE_DIR/ComfyUI/custom_nodes/$repo/requirements.txt"
    else
        echo "⚠️ No requirements.txt found for $repo, skipping installation."
    fi
done

# Start ComfyUI in the background
echo "🚀 Starting ComfyUI..."
cd "$BASE_DIR/ComfyUI"
python main.py --listen &
