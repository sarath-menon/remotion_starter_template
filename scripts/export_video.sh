#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
OUTPUT_DIR="$PROJECT_ROOT/output"
TIMESTAMP=$(date +%s)
DEFAULT_OUTPUT_FILE="video_$TIMESTAMP.mp4"

CONFIG_FILE=""
OUTPUT_FILE="$DEFAULT_OUTPUT_FILE"

usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -c, --config FILE    Path to JSON configuration file (required)"
    echo "  -o, --output FILE    Output filename (default: video_TIMESTAMP.mp4)"
    echo "  -h, --help          Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 -c config.json"
    echo "  $0 -c config.json -o my_video.mp4"
    exit 1
}

while [[ $# -gt 0 ]]; do
    case $1 in
        -c|--config)
            CONFIG_FILE="$2"
            shift 2
            ;;
        -o|--output)
            OUTPUT_FILE="$2"
            shift 2
            ;;
        -h|--help)
            usage
            ;;
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac
done

if [[ -z "$CONFIG_FILE" ]]; then
    echo "Error: Configuration file is required"
    echo "Use -h or --help for usage information"
    exit 1
fi

if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "Error: Configuration file '$CONFIG_FILE' not found"
    exit 1
fi

echo "=== Remotion Video Export ==="
echo "Project root: $PROJECT_ROOT"
echo "Config file: $CONFIG_FILE"
echo "Output directory: $OUTPUT_DIR"
echo "Output file: $OUTPUT_FILE"
echo ""

mkdir -p "$OUTPUT_DIR"

cd "$PROJECT_ROOT"

echo "Installing/updating dependencies..."
npm install

echo ""
echo "Rendering video with Remotion..."
echo "Command: npx remotion render DynamicVideoComposition \"$OUTPUT_DIR/$OUTPUT_FILE\" --props=\"$CONFIG_FILE\""

npx remotion render DynamicVideoComposition "$OUTPUT_DIR/$OUTPUT_FILE" --props="$CONFIG_FILE"

if [[ -f "$OUTPUT_DIR/$OUTPUT_FILE" ]]; then
    echo ""
    echo "✅ Video exported successfully!"
    echo "📁 Location: $OUTPUT_DIR/$OUTPUT_FILE"
    echo "📊 File size: $(du -h "$OUTPUT_DIR/$OUTPUT_FILE" | cut -f1)"
else
    echo ""
    echo "❌ Video export failed - output file not found"
    exit 1
fi