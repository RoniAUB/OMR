#!/bin/bash
# ============================================================================
# OMR Models Inference Runner - Bash Wrapper
# Run all OMR models on the same input image
# ============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

show_help() {
    echo ""
    echo "OMR Models Inference Runner"
    echo "============================"
    echo ""
    echo "Usage: $0 --input <image> [options]"
    echo ""
    echo "Options:"
    echo "  --input, -i     Path to input image (required)"
    echo "  --output, -o    Output directory (default: ./omr_results)"
    echo "  --models, -m    Comma-separated list of models to run"
    echo "  --device, -d    Device: cpu or cuda (default: cpu)"
    echo "  --timeout, -t   Timeout per model in seconds (default: 300)"
    echo "  --list          List all available models"
    echo "  --help, -h      Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 --input score.png"
    echo "  $0 --input score.png --models homr,oemer,legato"
    echo "  $0 --input score.png --device cuda --output ./results"
    echo ""
}

# Parse arguments
INPUT=""
OUTPUT="./omr_results"
MODELS=""
DEVICE="cpu"
TIMEOUT=300
LIST_MODELS=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -i|--input)
            INPUT="$2"
            shift 2
            ;;
        -o|--output)
            OUTPUT="$2"
            shift 2
            ;;
        -m|--models)
            MODELS="$2"
            shift 2
            ;;
        -d|--device)
            DEVICE="$2"
            shift 2
            ;;
        -t|--timeout)
            TIMEOUT="$2"
            shift 2
            ;;
        --list)
            LIST_MODELS=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            show_help
            exit 1
            ;;
    esac
done

# Check if conda is available
if ! command -v conda &> /dev/null; then
    echo -e "${RED}Error: Conda is not installed or not in PATH${NC}"
    exit 1
fi

# Initialize conda
eval "$(conda shell.bash hook)"

# List models
if [ "$LIST_MODELS" = true ]; then
    python "$SCRIPT_DIR/run_all_inference.py" --list-models
    exit 0
fi

# Check input
if [ -z "$INPUT" ]; then
    echo -e "${RED}Error: --input is required${NC}"
    show_help
    exit 1
fi

if [ ! -f "$INPUT" ]; then
    echo -e "${RED}Error: Input file not found: $INPUT${NC}"
    exit 1
fi

# Build command
CMD="python \"$SCRIPT_DIR/run_all_inference.py\" --input \"$INPUT\" --output \"$OUTPUT\" --device $DEVICE --timeout $TIMEOUT --base-dir \"$BASE_DIR\""

if [ -n "$MODELS" ]; then
    CMD="$CMD --models $MODELS"
fi

# Run
echo -e "${CYAN}Running OMR inference...${NC}"
eval $CMD
