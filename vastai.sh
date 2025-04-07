#!/bin/bash

source /venv/main/bin/activate
COMFYUI_DIR=${WORKSPACE}/ComfyUI

APT_PACKAGES=( 
    #"package-1"
    #"package-2"
)

PIP_PACKAGES=( 
    #"package-1"
    #"package-2"
)

NODES=( 
    "https://github.com/ltdrdata/ComfyUI-Manager"
    "https://github.com/rgthree/rgthree-comfy"
    "https://github.com/ltdrdata/ComfyUI-Impact-Pack"
    "https://github.com/ltdrdata/ComfyUI-Impact-Subpack"
    "https://github.com/Suzie1/ComfyUI_Comfyroll_CustomNodes"
    "https://github.com/ai-shizuka/ComfyUI-tbox"
    "https://github.com/alt-key-project/comfyui-dream-project"
    "https://github.com/Derfuu/Derfuu_ComfyUI_ModdedNodes"
    "https://github.com/FizzleDorf/ComfyUI_FizzNodes"
    "https://github.com/Gourieff/ComfyUI-ReActor"
    "https://github.com/TinyTerra/ComfyUI_tinyterraNodes"
    "https://github.com/chrisgoringe/cg-use-everywhere"
    "https://github.com/storyicon/comfyui_segment_anything"
    "https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite"
    "https://github.com/kijai/ComfyUI-KJNodes"
    "https://github.com/WASasquatch/was-node-suite-comfyui"
    "https://github.com/Fannovel16/comfyui_controlnet_aux"
)

WORKFLOWS=( 
)

CHECKPOINT_MODELS=( 
    "https://civitai.com/api/download/models/1379960?token=$CIVITAI_TOKEN"
)

LORA_CHARACTERS=( 
    "https://civitai.com/api/download/models/1453689?token=$CIVITAI_TOKEN"
    "https://civitai.com/api/download/models/1451050?token=$CIVITAI_TOKEN"
    "https://civitai.com/api/download/models/1245593?token=$CIVITAI_TOKEN"
    "https://civitai.com/api/download/models/1593973?token=$CIVITAI_TOKEN"
    "https://civitai.com/api/download/models/1593945?token=$CIVITAI_TOKEN"
    "https://civitai.com/api/download/models/1593987?token=$CIVITAI_TOKEN"
    "https://civitai.com/api/download/models/1594005?token=$CIVITAI_TOKEN"
    "https://civitai.com/api/download/models/1593929?token=$CIVITAI_TOKEN"
    "https://civitai.com/api/download/models/1372788?token=$CIVITAI_TOKEN"
    "https://civitai.com/api/download/models/1247539?token=$CIVITAI_TOKEN"
    "https://civitai.com/api/download/models/1098813?token=$CIVITAI_TOKEN"
)

LORA_STYLES=( 
    "https://civitai.com/api/download/models/1570070?token=$CIVITAI_TOKEN"
    "https://civitai.com/api/download/models/1067949?token=$CIVITAI_TOKEN"
)

LORA_CLOTHING=(
    "https://civitai.com/api/download/models/1257965?token=$CIVITAI_TOKEN"
    "https://civitai.com/api/download/models/1307299?token=$CIVITAI_TOKEN"
    "https://civitai.com/api/download/models/1533931?token=$CIVITAI_TOKEN"
    "https://civitai.com/api/download/models/1525419?token=$CIVITAI_TOKEN"
    "https://civitai.com/api/download/models/1533873?token=$CIVITAI_TOKEN"
)


LORA_CONCEPT=(
    "https://civitai.com/api/download/models/1571734?token=$CIVITAI_TOKEN"
    "https://civitai.com/api/download/models/1388229?token=$CIVITAI_TOKEN"

)

ADETAILER_MODELS=( 
    "https://civitai.com/api/download/models/465360?token=$CIVITAI_TOKEN"
)


function provisioning_start() {
    provisioning_print_header
    provisioning_get_apt_packages
    provisioning_get_nodes
    provisioning_get_pip_packages
    provisioning_get_files \
        "${COMFYUI_DIR}/models/checkpoints" \
        "${CHECKPOINT_MODELS[@]}"
    provisioning_get_files \
        "${COMFYUI_DIR}/models/loras/characters" \
        "${LORA_CHARACTERS[@]}"
    provisioning_get_files \
        "${COMFYUI_DIR}/models/loras/styles" \
        "${LORA_STYLES[@]}"
    provisioning_get_files \
        "${COMFYUI_DIR}/models/loras/clothing" \
        "${LORA_CLOTHING[@]}"
    provisioning_get_files \
        "${COMFYUI_DIR}/models/loras/concept" \
        "${LORA_CONCEPT[@]}"
    provisioning_get_files \
        "${COMFYUI_DIR}/models/ultralytics/segm" \
        "${ADETAILER_MODELS[@]}"
    provisioning_print_end
}

function provisioning_get_apt_packages() {
    if [[ ${#APT_PACKAGES[@]} -gt 0 ]]; then
        sudo $APT_INSTALL ${APT_PACKAGES[@]}
    fi
}

function provisioning_get_pip_packages() {
    if [[ ${#PIP_PACKAGES[@]} -gt 0 ]]; then
        pip install --no-cache-dir ${PIP_PACKAGES[@]}
    fi
}

function provisioning_get_nodes() {
    for repo in "${NODES[@]}"; do
        dir="${repo##*/}"
        path="${COMFYUI_DIR}/custom_nodes/${dir}"
        requirements="${path}/requirements.txt"
        if [[ -d $path ]]; then
            if [[ ${AUTO_UPDATE,,} != "false" ]]; then
                printf "Updating node: %s...\n" "${repo}"
                ( cd "$path" && git pull )
                if [[ -e $requirements ]]; then
                   pip install --no-cache-dir -r "$requirements"
                fi
            fi
        else
            printf "Downloading node: %s...\n" "${repo}"
            git clone "${repo}" "${path}" --recursive
            if [[ -e $requirements ]]; then
                pip install --no-cache-dir -r "${requirements}"
            fi
        fi
    done
}

function provisioning_get_files() {
    if [[ ${#@} -lt 2 ]]; then return 1; fi
    
    dir="$1"
    mkdir -p "$dir"
    shift
    arr=("$@")
    printf "Downloading %s model(s) to %s...\n" "${#arr[@]}" "$dir"
    for url in "${arr[@]}"; do
        printf "Downloading: %s\n" "${url}"
        provisioning_download "${url}" "${dir}"
        printf "\n"
    done
}

function provisioning_print_header() {
    printf "\n##############################################\n#                                            #\n#          Provisioning container            #\n#                                            #\n#         This will take some time           #\n#                                            #\n# Your container will be ready on completion #\n#                                            #\n##############################################\n\n"
}

function provisioning_print_end() {
    printf "\nProvisioning complete:  Application will start now\n\n"
}

# Download from $1 URL to $2 file path
function provisioning_download() {
    # Use simplified wget without headers or authentication
    wget --content-disposition "$1" -P "$2"
}

# Allow user to disable provisioning if they started with a script they didn't want
if [[ ! -f /.noprovisioning ]]; then
    provisioning_start
fi
