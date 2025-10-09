#!/bin/bash

# Find Flutter installation directory
echo "Finding Flutter installation directory..."

# Check common Flutter installation paths
FLUTTER_DIR=""

# Check if flutter is in PATH
if command -v flutter &> /dev/null; then
    FLUTTER_PATH=$(which flutter)
    FLUTTER_DIR=$(dirname "$(dirname "$FLUTTER_PATH")")
    echo "Found Flutter in PATH: $FLUTTER_DIR"
elif [ -d "$HOME/flutter" ]; then
    FLUTTER_DIR="$HOME/flutter"
    echo "Found Flutter in home directory: $FLUTTER_DIR"
elif [ -d "/usr/local/flutter" ]; then
    FLUTTER_DIR="/usr/local/flutter"
    echo "Found Flutter in /usr/local: $FLUTTER_DIR"
elif [ -d "/opt/flutter" ]; then
    FLUTTER_DIR="/opt/flutter"
    echo "Found Flutter in /opt: $FLUTTER_DIR"
else
    echo "Flutter installation not found. Please ensure Flutter is installed."
    exit 1
fi

# Delete flutter_tools.stamp file to trigger rebuild
STAMP_FILE="$FLUTTER_DIR/bin/cache/flutter_tools.stamp"
if [ -f "$STAMP_FILE" ]; then
    echo "Deleting flutter_tools.stamp file: $STAMP_FILE"
    rm "$STAMP_FILE"
    echo "flutter_tools.stamp deleted successfully"
else
    echo "flutter_tools.stamp file not found at: $STAMP_FILE"
fi

# Also check for flutter_tools.snapshot and delete it to force rebuild
SNAPSHOT_FILE="$FLUTTER_DIR/bin/cache/flutter_tools.snapshot"
if [ -f "$SNAPSHOT_FILE" ]; then
    echo "Deleting flutter_tools.snapshot file: $SNAPSHOT_FILE"
    rm "$SNAPSHOT_FILE"
    echo "flutter_tools.snapshot deleted successfully"
fi

echo "Flutter tools will be rebuilt on next flutter command execution"

# Function to remove --disable-extension from Chrome debug commands
remove_disable_extension() {
    local file="$1"
    if [ -f "$file" ]; then
        echo "Processing file: $file"
        # Use sed to remove --disable-extension flag
        sed -i.bak 's/--disable-extensions//g' "$file"
        sed -i.bak 's/--disable-extension//g' "$file"
        echo "Removed --disable-extension flags from $file"
    fi
}

# Look for Flutter web debug configuration files
echo "Looking for Flutter web debug configurations..."

# Check common locations for Flutter web debug configs
WEB_CONFIG_DIRS=(
    "$FLUTTER_DIR/packages/flutter_tools/lib/src/web"
    "$FLUTTER_DIR/packages/flutter_tools/lib/src/commands"
    "$HOME/.flutter"
    "$(pwd)/.dart_tool"
    "$(pwd)/web"
)

for dir in "${WEB_CONFIG_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        echo "Checking directory: $dir"
        # Find files that might contain Chrome launch configurations
        find "$dir" -type f \( -name "*.dart" -o -name "*.json" -o -name "*.yaml" -o -name "*.yml" \) -exec grep -l "disable-extension\|disable-extensions" {} \; 2>/dev/null | while read -r file; do
            remove_disable_extension "$file"
        done
    fi
done

# Also check current project for launch configurations
if [ -f ".vscode/launch.json" ]; then
    echo "Found VS Code launch configuration"
    remove_disable_extension ".vscode/launch.json"
fi

echo "Script completed successfully!"
echo "Note: Flutter tools will rebuild automatically on the next flutter command."
echo "Chrome extensions should now be enabled in Flutter web debug mode."
