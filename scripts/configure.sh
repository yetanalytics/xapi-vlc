#!/bin/bash

source "$(dirname "$0")/get-config-dir.sh"


delete_if_exists() {
  local file_path="$1"  # The file path is passed as an argument

  # Check if the file exists
  if [ -f "$file_path" ]; then
    echo "File exists: $file_path"
    
    # Delete the file
    rm "$file_path"
    echo "File deleted: $file_path"
  else
    echo "File does not exist: $file_path"
  fi
}

configure() {
  local xapi_config_file="$(get_vlc_config_directory)xapi-extension-config.txt"
  local threshold_config_file="$(get_vlc_config_directory)xapi-threshold-config.txt" 
  
  delete_if_exists "$xapi_config_file"
  delete_if_exists "$threshold_config_file"

  # Variables to store the required options
  local api_key=""
  local api_secret=""
  local api_endpoint=""
  local threshold=""
  local homepage=""

  # Parse command line options
  while getopts "k:s:u:t:h:" opt; do
    case $opt in
      k)
        api_key="$OPTARG"
        ;;
      s)
        api_secret="$OPTARG"
        ;;
      u)
        api_endpoint="$OPTARG"
        ;;
      t)
        threshold="$OPTARG"
        ;;
      h)
        homepage="$OPTARG"
        ;;
      *)
        echo "Usage: $0 -k <api_key> -s <api_secret> -u <api_endpoint> -t <threshold> -h <homepage>"
        exit 1
        ;;
    esac
  done

  
  # Debugging: Output parsed values
  echo "API Key: $api_key"
  echo "API Secret: $api_secret"
  echo "API URL: $api_endpoint"
  echo "Threshold: $threshold"
  echo "API Homepage: $homepage"

  
  # Write the key-value pairs to the file, only if they exist
  [[ -n "$api_key" ]] && echo "api_key = $api_key" >> "$xapi_config_file"
  [[ -n "$api_secret" ]] && echo "api_secret = $api_secret" >> "$xapi_config_file"
  [[ -n "$api_endpoint" ]] && echo "api_endpoint = $api_endpoint" >> "$xapi_config_file"
  [[ -n "$threshold" ]] && echo "threshold = $threshold" >> "$threshold_config_file"
  [[ -n "$homepage" ]] && echo "api_homepage = $homepage" >> "$xapi_config_file"

  echo "config written to $xapi_config_file and threshold written to $threshold_config_file"

  return 0
}

#echo "$(get_vlc_config_directory)"

configure "$@"
