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

write_config() {
  local file_path="$(get_vlc_config_directory)xapi-extension-config.txt"
  shift  # Remove the file_path from the arguments list

  # Variables to store the required options
  local api_key=""
  local api_secret=""
  local api_url=""
  local threshold=""

  # Parse command line options
  while getopts "k:s:u:t:" opt; do
    case $opt in
      k)
        api_key="$OPTARG"
        ;;
      s)
        api_secret="$OPTARG"
        ;;
      u)
        api_url="$OPTARG"
        ;;
      t)
        threshold="$OPTARG"
        ;;
      *)
        echo "Usage: $0 -k <api_key> -s <api_secret> -u <api_url> -t <threshold>"
        exit 1
        ;;
    esac
  done

  
  # Debugging: Output parsed values
  echo "API Key: $api_key"
  echo "API Secret: $api_secret"
  echo "API URL: $api_url"
  echo "Threshold: $threshold"


  # Ensure all required options are provided
  #if [[ -z "$api_key" || -z "$api_secret" || -z "$url" || -z "$threshold" ]]; then
  #  echo "Error: Missing required options." >&2
  #  echo "Usage: $0 <config_file> --api-key <key> --api-secret <secret> --api-url <url> --threshold <threshold>" >&2
  #  return 1
  #fi
  
  # Write the key-value pairs to the file, only if they exist
  [[ -n "$api_key" ]] && echo "api_key = $api_key" >> "$file_path"
  [[ -n "$api_secret" ]] && echo "api_secret = $api_secret" >> "$file_path"
  [[ -n "$api_url" ]] && echo "api_url = $api_url" >> "$file_path"
  [[ -n "$threshold" ]] && echo "threshold = $threshold" >> "$file_path"

  echo "config written to $file_path"

  return 0
}

#echo "$(get_vlc_config_directory)"

write_config "$@"
