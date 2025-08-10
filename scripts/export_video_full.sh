#!/bin/bash

set -e

CONFIG_JSON="$1"  # JSON config as first argument
OUTPUT_NAME="$2"  # Output filename as second argument
WORKSPACE_DIR="$3"  # Workspace directory

if [[ -z "$CONFIG_JSON" || -z "$OUTPUT_NAME" || -z "$WORKSPACE_DIR" ]]; then
    echo "Usage: $0 <config_json> <output_name> <workspace_dir>"
    echo "Example: $0 '{\"composition\":{...}}' 'my_video' '/path/to/workspace'"
    exit 1
fi

TIMESTAMP=$(date +%s)
CONFIG_FILE="config_$TIMESTAMP.json"

# Detect if we're in a session workspace or standalone template
if [[ -d "$WORKSPACE_DIR/remotion_project" ]]; then
    # Session workspace structure
    REMOTION_DIR="$WORKSPACE_DIR/remotion_project"
    FINAL_OUTPUT_DIR="$WORKSPACE_DIR/output"
else
    # Standalone template structure
    REMOTION_DIR="$WORKSPACE_DIR"
    FINAL_OUTPUT_DIR="$WORKSPACE_DIR/output"
fi

echo "=== Remotion Full Export ==="
echo "Config: $CONFIG_JSON"
echo "Output name: $OUTPUT_NAME"
echo "Workspace: $WORKSPACE_DIR"
echo "Remotion dir: $REMOTION_DIR"
echo ""

# Validate directories
if [[ ! -d "$REMOTION_DIR" ]]; then
    echo "❌ Error: Remotion directory not found: $REMOTION_DIR"
    exit 1
fi

if [[ ! -f "$REMOTION_DIR/scripts/export_video.sh" ]]; then
    echo "❌ Error: export_video.sh script not found in: $REMOTION_DIR/scripts/"
    exit 1
fi

# 1. Write config file (the export_video.sh script will handle the wrapping)
echo "📝 Writing config file..."
echo "$CONFIG_JSON" > "$REMOTION_DIR/$CONFIG_FILE"

if [[ ! -f "$REMOTION_DIR/$CONFIG_FILE" ]]; then
    echo "❌ Error: Failed to write config file"
    exit 1
fi

echo "✅ Config written to: $REMOTION_DIR/$CONFIG_FILE"

# 2. Export video
echo ""
echo "🎬 Exporting video..."
cd "$REMOTION_DIR"

# Use the existing export script which handles npm install and all the rendering
./scripts/export_video.sh --config "$CONFIG_FILE" --output "$OUTPUT_NAME"

# Check if video was created (Remotion adds .mp4 automatically)
VIDEO_FILE="output/$OUTPUT_NAME.mp4"
if [[ ! -f "$VIDEO_FILE" ]]; then
    # Try without extension in case it was already added
    VIDEO_FILE="output/$OUTPUT_NAME"
    if [[ ! -f "$VIDEO_FILE" ]]; then
        echo "❌ Error: Video export failed - output file not found"
        echo "Expected: output/$OUTPUT_NAME.mp4"
        echo "Contents: $(ls -la output/ 2>/dev/null || echo 'output directory not found')"
        exit 1
    fi
fi

# 3. Move to final workspace location
echo ""
echo "📁 Organizing output..."
mkdir -p "$FINAL_OUTPUT_DIR"
TIMESTAMP_SUFFIX=$(date +%Y%m%d_%H%M%S)
FINAL_NAME="${OUTPUT_NAME}_${TIMESTAMP_SUFFIX}.mp4"
FINAL_PATH="$FINAL_OUTPUT_DIR/$FINAL_NAME"

cp "$VIDEO_FILE" "$FINAL_PATH"

if [[ ! -f "$FINAL_PATH" ]]; then
    echo "❌ Error: Failed to copy video to final location"
    exit 1
fi

# 4. Return success info
echo "✅ Video export completed successfully!"
echo "📁 Final location: $FINAL_PATH"
echo "📊 File size: $(du -h "$FINAL_PATH" | cut -f1)"
echo ""
echo "FINAL_PATH:$FINAL_PATH"