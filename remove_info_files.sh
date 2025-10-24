#!/bin/bash

# Script to remove all .info files in the ./files directory and subdirectories

echo "Removing all .info files from ./files directory..."

find ./files -name "*.info" -type f -delete

echo "All .info files have been removed."