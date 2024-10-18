#!/bin/bash

get_vlc_config_directory() {
  local config_dir=""

  # Check the OS type using uname
  if [[ "$(uname)" == "Darwin" ]]; then
    # macOS
    if [[ -n "$HOME" ]]; then
      config_dir="$HOME/Library/Preferences/org.videolan.vlc/"
    fi
  elif [[ "$(uname)" == "Linux" ]]; then
    # Linux
    if [[ -n "$HOME" ]]; then
      config_dir="$HOME/.config/vlc/"
    fi
  elif [[ "$(uname -o 2>/dev/null)" == "Cygwin" || "$(uname -o 2>/dev/null)" == "Msys" || "$(uname -o 2>/dev/null)" == "MINGW32_NT" || "$(uname -o 2>/dev/null)" == "MINGW64_NT" ]]; then
    # Windows (Cygwin or WSL environments can also be checked)
    if [[ -n "$APPDATA" ]]; then
      config_dir="$APPDATA/vlc/"
    fi
  fi

  # Check if config directory was determined
  if [[ -z "$config_dir" ]]; then
    echo "Could not determine VLC configuration directory." >&2
    return 1
  fi

  # Ensure the directory exists
  if [[ ! -d "$config_dir" ]]; then
    mkdir -p "$config_dir"
    if [[ $? -ne 0 ]]; then
      echo "Failed to create directory: $config_dir" >&2
      return 1
    fi
  fi

  echo "$config_dir"
  return 0
}
