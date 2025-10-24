#!/bin/bash

# Cleanup script for stale tusd uploads
# Usage: ./cleanup_stale_uploads.sh [hours]
# Default: 24 hours
# Removes .info files for uploads that haven't been modified in the specified hours
# This helps clean up failed/abandoned uploads

HOURS=${1:-24}  # Default to 24 hours if no argument provided
MINUTES=$((HOURS * 60))

echo "Cleaning up stale tusd uploads (older than $HOURS hours)..."

# Find .info files older than specified hours and remove them along with their data files
find ./files -name "*.info" -type f -mmin +$MINUTES -exec bash -c '
    info_file="$1"
    data_file="${info_file%.info}"
    echo "Removing stale upload: $info_file and $data_file"
    rm -f "$info_file" || true
    rm -f "$data_file" || true
' _ {} \;

# Also remove any orphaned .info files (without corresponding data file)
find ./files -name "*.info" -type f -exec bash -c '
    info_file="$1"
    data_file="${info_file%.info}"
    if [ ! -f "$data_file" ]; then
        echo "Removing orphaned .info file: $info_file"
        rm -f "$info_file"
    fi
' _ {} \;

echo "Cleanup complete."