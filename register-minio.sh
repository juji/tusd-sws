#!/usr/bin/env bash
# Safe MinIO register script: each visible subdirectory becomes a bucket
# Recursively uploads all non-dot files, skips existing objects

set -euo pipefail

DIRECTORY="${1:-files}"   # root folder containing buckets
ALIAS="${2:-myminio}"     # mc alias

TEMP_DIR="$(mktemp -d)"
echo "temp: $TEMP_DIR"

cd "$DIRECTORY" || { echo "❌ cannot cd to $DIRECTORY"; exit 1; }

ROOT="$(pwd)"
echo "Root directory: $ROOT"
echo "MinIO alias: $ALIAS"
echo

for DIR in */; do
  [[ "$DIR" == .* ]] && continue      # skip hidden directories
  [ -d "$DIR" ] || continue

  BUCKET="${DIR%/}"
  echo "→ bucket: $BUCKET"
  mc mb "${ALIAS}/${BUCKET}" --ignore-existing >/dev/null 2>&1 || true

  # Recursively find visible files (skip dotfiles)
  find "$DIR" -type f ! -path '*/.*' -print0 | while IFS= read -r -d '' FILE; do
    # Remove the bucket directory prefix from the file path
    REL_PATH="${FILE#$DIR}"
    REL_PATH="${REL_PATH#/}"    # normalize
    [ -z "$REL_PATH" ] && continue

    SRC="${ROOT}/${FILE}"
    DEST="${ALIAS}/${BUCKET}/${REL_PATH}"

    if ! mc stat "$DEST" >/dev/null 2>&1; then
      echo "Uploading: $REL_PATH"
      DEST_DIR="$(dirname "$TEMP_DIR/$FILE")"
      mkdir -p "$DEST_DIR"
      mv "$SRC" "$TEMP_DIR/$FILE"
      # mc cp "$TEMP_DIR/$FILE" "$DEST" >/dev/null
      mc cp "$TEMP_DIR/$FILE" "$DEST"
      rm -f "$TEMP_DIR/$FILE"
    fi
    
  done

done

rm -rf "$TEMP_DIR"
echo
echo "✅ Done registering all subdirectories."