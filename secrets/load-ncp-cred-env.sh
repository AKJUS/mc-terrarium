#!/bin/bash

# Check if the script is being sourced
(return 0 2>/dev/null) && SOURCED=1 || SOURCED=0

if [ $SOURCED -eq 0 ]; then
    echo "Error: This script must be sourced to work properly."
    echo "Usage:"
    echo "  source $0"
    echo "  or"
    echo "  . $0"
    exit 1
fi

# Find the script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/credential-ncp.env"

echo "Loading credential from '${ENV_FILE##*/}'"

# Check if .env file exists
if [[ -f "$ENV_FILE" ]]; then
    sed -i 's/\r$//' "$ENV_FILE"  # Remove carriage return characters
    while IFS= read -r line || [[ -n "$line" ]]; do
        # Skip empty lines and comments
        if [[ -n "$line" && ! "$line" =~ ^# ]]; then
            # echo "Processing line: $line"  # Debugging line
            export "$line"            
        fi
    done < "$ENV_FILE"
    echo "Successfully loaded"
else
    echo "Error: does not exist file, $ENV_FILE"
fi