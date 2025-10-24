#!/bin/bash

# Post-upload hook to rename file to original filename and remove .info file
# This preserves the original filename with extension

echo "Upload $TUS_ID completed."

# If filename metadata exists, rename the file
if [ -n "$TUS_META_filename" ]; then
    ORIGINAL_NAME="$TUS_META_filename"
    CURRENT_PATH="$TUS_FILE_PATH"
    DIR_PATH=$(dirname "$CURRENT_PATH")
    NEW_PATH="$DIR_PATH/$ORIGINAL_NAME"

    echo "Renaming $CURRENT_PATH to $NEW_PATH"

    # Rename the file to use original filename
    mv "$CURRENT_PATH" "$NEW_PATH"

    # Update TUS_FILE_PATH for the .info removal below
    TUS_FILE_PATH="$NEW_PATH"
fi

# Remove the .info file
rm -f "$TUS_FILE_PATH.info"

echo "Cleanup completed for upload $TUS_ID"