#!/bin/bash

# Post-terminate hook - called after tusd terminates an upload
# Tusd automatically removes both the .info file and data file when terminated
# This hook can be used for additional cleanup or logging

echo "Upload $TUS_ID has been terminated and cleaned up by tusd."