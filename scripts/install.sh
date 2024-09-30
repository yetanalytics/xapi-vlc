#!/bin/bash

# Set the source file path
SOURCE_FILE="xapi.lua"

# Check if the file exists
if [ ! -f "$SOURCE_FILE" ]; then
  echo "Error: $SOURCE_FILE not found."
  exit 1
fi

# Determine the OS and set the target directory
TARGET_DIR=""

if [[ "$OSTYPE" == "linux"* ]]; then
  TARGET_DIR="$HOME/.local/share/vlc/lua/extensions"

elif [[ "$OSTYPE" == "darwin"* ]]; then
  TARGET_DIR="$HOME/Library/Application Support/org.videolan.vlc/lua/extensions"

elif [[ "$OSTYPE" == "cygwin" || "$OSTYPE" == "msys" || "$OSTYPE" == "win32" ]]; then
  # This assumes you're using WSL or a similar environment.
  TARGET_DIR="$HOME/.local/share/vlc/lua/extensions"

else
  echo "Unsupported operating system: $OSTYPE"
  exit 1
fi

# Create the target directory if it doesn't exist
mkdir -p "$TARGET_DIR"

# Copy the xapi.lua file to the target directory
cp "$SOURCE_FILE" "$TARGET_DIR"

if [ $? -eq 0 ]; then
  echo "xapi.lua has been successfully copied to $TARGET_DIR . Restart VLC to enable extension."
else
  echo "Error: Failed to copy xapi.lua"
fi
