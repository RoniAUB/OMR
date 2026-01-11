#!/bin/bash
# ============================================================================
# OMR Models Setup Script for Linux/macOS
# This script clones all OMR model repositories and sets up their environments
# ============================================================================

set -e

BASE_DIR="${1:-$HOME/CodesOMR}"
SKIP_CLONE=false
SKIP_ENV=false

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

log_status() { echo -e "${CYAN}[*] $1${NC}"; }
log_success() { echo -e "${GREEN}[+] $1${NC}"; }
log_warning() { echo -e "${YELLOW}[!] $1${NC}"; }
log_error() { echo -e "${RED}[-] $1${NC}"; }

# ============================================================================
# Repository Configuration
# ============================================================================
declare -A REPOS

# Format: "name|url|branch|python_version|install_method|extra"
REPO_LIST=(
    "homr|https://github.com/liebharc/homr.git|main|3.11|poetry|End-to-end OMR using vision transformers"
    "oemer|https://github.com/meteo-team/oemer.git|main|3.10|setup|End-to-end OMR system"
    "SMT|https://github.com/antoniorv6/SMT.git|master|3.10|requirements|Sheet Music Transformer"
    "SMT-plusplus|https://github.com/antoniorv6/SMT-plusplus.git|master|3.10|requirements|Sheet Music Transformer++"
    "legato|https://github.com/guang-yng/legato.git|main|3.10|requirements|Legato OMR model"
    "Polyphonic-TrOMR|https://github.com/NetEase/Polyphonic-TrOMR.git|master|3.9|requirements|Polyphonic Transformer OMR"
    "tf-end-to-end|https://github.com/OMR-Research/tf-end-to-end.git|master|3.8|pip|TensorFlow end-to-end OMR"
    "keras-retinanet|https://github.com/fizyr/keras-retinanet.git|main|3.8|setup|Keras RetinaNet for object detection"
    "ObjectDetection-OMR|https://github.com/vgilabert94/ObjectDetection-OMR.git|master|3.8|custom|Object detection for OMR"
    "MarimbaBot|https://github.com/UHHRobotics22-23/MarimbaBot.git|main|3.10|requirements|MarimbaBot robotics and vision"
)

# ============================================================================
# Helper Functions
# ============================================================================

check_conda() {
    if command -v conda &> /dev/null; then
        log_success "Conda is installed"
        return 0
    else
        log_error "Conda is not installed. Please install Miniconda or Anaconda first."
        echo "Download from: https://docs.conda.io/en/latest/miniconda.html"
        return 1
    fi
}

check_git() {
    if command -v git &> /dev/null; then
        log_success "Git is installed"
        return 0
    else
        log_error "Git is not installed. Please install Git first."
        return 1
    fi
}

create_conda_env() {
    local env_name=$1
    local python_version=$2
    
    log_status "Creating conda environment: $env_name (Python $python_version)"
    
    if conda env list | grep -q "^$env_name "; then
        log_warning "Environment '$env_name' already exists, skipping creation"
        return 0
    fi
    
    conda create -n "$env_name" python="$python_version" -y
    log_success "Created environment: $env_name"
}

install_dependencies() {
    local env_name=$1
    local repo_path=$2
    local install_method=$3
    
    log_status "Installing dependencies for $env_name..."
    
    case $install_method in
        "requirements")
            if [ -f "$repo_path/requirements.txt" ]; then
                conda run -n "$env_name" pip install -r "$repo_path/requirements.txt"
            else
                log_warning "requirements.txt not found in $repo_path"
            fi
            ;;
        "setup")
            pushd "$repo_path" > /dev/null
            conda run -n "$env_name" pip install -e .
            popd > /dev/null
            ;;
        "poetry")
            pushd "$repo_path" > /dev/null
            conda run -n "$env_name" pip install poetry
            conda run -n "$env_name" poetry install
            popd > /dev/null
            ;;
        "pip")
            # For tf-end-to-end
            conda run -n "$env_name" pip install tensorflow numpy opencv-python
            ;;
        "custom")
            log_warning "Custom installation required for $env_name. See repository README."
            ;;
    esac
    
    log_success "Dependencies installed for $env_name"
}

# ============================================================================
# Main Script
# ============================================================================

echo ""
echo "========================================================"
echo "       OMR Models Setup Script (Linux/macOS)            "
echo "========================================================"
echo ""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-clone)
            SKIP_CLONE=true
            shift
            ;;
        --skip-env)
            SKIP_ENV=true
            shift
            ;;
        --base-dir)
            BASE_DIR="$2"
            shift 2
            ;;
        *)
            shift
            ;;
    esac
done

# Check prerequisites
check_conda || exit 1
check_git || exit 1

# Initialize conda for script
eval "$(conda shell.bash hook)"

# Create base directory
mkdir -p "$BASE_DIR"
cd "$BASE_DIR"

# Process each repository
for repo_info in "${REPO_LIST[@]}"; do
    IFS='|' read -r name url branch python_version install_method description <<< "$repo_info"
    
    echo ""
    echo "--------------------------------------------------------"
    echo "  Setting up: $name"
    echo "  $description"
    echo "--------------------------------------------------------"
    
    repo_path="$BASE_DIR/$name"
    
    # Clone repository
    if [ "$SKIP_CLONE" = false ]; then
        if [ -d "$repo_path" ]; then
            log_warning "Repository already exists: $name"
            log_status "Pulling latest changes..."
            pushd "$repo_path" > /dev/null
            git pull origin "$branch" || true
            popd > /dev/null
        else
            log_status "Cloning $url..."
            git clone --branch "$branch" "$url" "$repo_path"
            log_success "Cloned: $name"
        fi
    fi
    
    # Create environment and install dependencies
    if [ "$SKIP_ENV" = false ]; then
        create_conda_env "$name" "$python_version"
        install_dependencies "$name" "$repo_path" "$install_method"
    fi
done

echo ""
echo "========================================================"
echo "  Setup Complete!"
echo "========================================================"
echo ""
echo "To activate an environment, use:"
echo "  conda activate <model-name>"
echo ""
echo "Available environments:"
for repo_info in "${REPO_LIST[@]}"; do
    IFS='|' read -r name _ <<< "$repo_info"
    echo "  - $name"
done
echo ""
