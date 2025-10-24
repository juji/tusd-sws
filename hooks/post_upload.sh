#!/bin/bash

# Post-upload hook to remove .info file after successful upload
# This is optional and removes the metadata file once upload is complete

echo "Upload $TUS_ID completed. Removing .info file."

# Remove the .info file
rm -f "$TUS_FILE_PATH.info"

echo "Removed $TUS_FILE_PATH.info"