#!/bin/bash

CONFIG="$HOME/.config/wlr-which-key/config.yaml"
THEME="$HOME/.config/wlr-which-key/theme.yaml"
TEMP_FILE=$(mktemp)

# Check if files exist
if [[ ! -f "$CONFIG" || ! -f "$THEME" ]]; then
    echo "Error: Config or Theme file not found."
    exit 1
fi

# 1. Remove existing background, color, and border lines
# We use -E for extended regex to catch any leading whitespace
sed -E '/^\s*(background|color|border):/d' "$CONFIG" > "$TEMP_FILE"

# 2. Append the contents of theme.yaml to the bottom
cat "$THEME" >> "$TEMP_FILE"

# 3. Move the temp file back to the original config
mv "$TEMP_FILE" "$CONFIG"

echo "wlr-which-key config updated with new theme."
