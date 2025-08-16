#!/bin/bash

# Get the directory where this script is located
SCRIPT_DIR="$HOME/Storagebox/GIT/pin"
#SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

# If multiple arguments are provided, launch pin for each file
if [[ $# -gt 1 ]]; then
  # Launch pin for each file argument
  for file in "$@"; do
    if [[ -f "$file" ]]; then
      nohup "$SCRIPT_DIR/pin" "$file" >/dev/null 2>&1 &
    fi
  done
else
  # Single file or no arguments - pass through normally
  nohup "$SCRIPT_DIR/pin" "$@" >/dev/null 2>&1 &
fi

#echo "Image viewer(s) launched independently"
