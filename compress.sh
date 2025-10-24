#!/usr/bin/env bash
ALIAS="myminio"
OUTPUT="backup.tar.gz"

# Use GNU tar (gtar) for --transform
for BUCKET in $(mc ls "$ALIAS" | awk '{print $5}'); do
    mc ls --recursive "$ALIAS/$BUCKET" | awk '{print $5}' | grep -v '^.minio.sys' | grep -v 'xl.meta' | while read -r OBJECT; do
        # Stream each object into tar.gz
        mc cat "$ALIAS/$BUCKET/$OBJECT" | gtar --transform="s|^|$BUCKET/|" -rf - - 
    done
done | gzip > "$OUTPUT"