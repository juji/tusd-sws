#!/bin/bash

# Benchmark script to compare tusd vs static-web-server performance
# Requires curl and time

TUSD_URL="http://localhost:8080/dir4/file_6564.txt"
SWS_URL="http://localhost:8787/dir4/file_6564.txt"

echo "Benchmarking file download performance..."
echo "Test file: dir4/file_6564.txt"
echo

echo "=== Tusd (port 8080) ==="
wrk -t4 -c100 -d30s $TUSD_URL
echo

echo "=== Static-Web-Server (port 8787) ==="
wrk -t4 -c100 -d30s $SWS_URL
echo

echo "For concurrent load testing, install 'wrk' and run:"
echo "wrk -t4 -c100 -d30s $TUSD_URL"
echo "wrk -t4 -c100 -d30s $SWS_URL"