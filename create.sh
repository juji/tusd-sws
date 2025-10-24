#!/bin/bash
# Create 5 directories with random nested files/subdirs inside a given root directory

set -euo pipefail

ROOT="${1:-files}"

cd "$ROOT" || { echo "❌ Cannot cd into $ROOT"; exit 1; }

echo "📂 Working directory: $(pwd)"
echo "Creating 5 directories with random content..."
echo

for i in {1..5}; do
  TOPDIR="dir$i"
  mkdir -p "$TOPDIR"

  echo "→ Populating $TOPDIR..."
  for j in {1..100}; do
    if (( RANDOM % 2 )); then
      # create a random file
      FILE="$TOPDIR/file_$RANDOM.txt"
      echo "This is $FILE" > "$FILE"
    else
      # create a random subdirectory with 3 files inside
      SUBDIR="$TOPDIR/subdir_$RANDOM"
      mkdir -p "$SUBDIR"
      for k in {1..3}; do
        FILE="$SUBDIR/file_${k}_$RANDOM.txt"
        echo "This is $FILE" > "$FILE"
      done
    fi
  done
done

echo
echo "✅ Done creating random directories and files under: $(pwd)"