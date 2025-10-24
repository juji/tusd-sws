#!/bin/bash

# Script to run both tusd and static-web-server in parallel (non-Docker setup)
# Requires: tusd (install from https://github.com/tus/tusd) and static-web-server

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to cleanup background processes on exit
cleanup() {
    echo -e "\n${YELLOW}Shutting down services...${NC}"
    kill 0  # Kill all processes in the current process group
    exit 0
}

# Set trap to cleanup on script exit
trap cleanup EXIT INT TERM

echo -e "${GREEN}Starting hybrid file server (tusd + static-web-server)...${NC}"
echo "Uploads: http://localhost:8080/"
echo "Downloads: http://localhost:8787/"
echo ""

# Check if tusd is available
if ! command -v tusd &> /dev/null; then
    echo -e "${RED}Error: tusd is not installed.${NC}"
    echo "Install tusd from: https://github.com/tus/tusd"
    echo "Example: go install github.com/tus/tusd/cmd/tusd@latest"
    exit 1
fi

# Check if static-web-server is available
if ! command -v static-web-server &> /dev/null; then
    echo -e "${RED}Error: static-web-server is not installed.${NC}"
    echo "Install static-web-server from: https://github.com/static-web-server/static-web-server"
    exit 1
fi

# Create files directory if it doesn't exist
mkdir -p ./files

echo -e "${YELLOW}Starting tusd (upload server) on port 8080...${NC}"
# Run tusd in background with CORS support
tusd -port 8080 -base-path / -hooks-dir ./hooks -disable-download -behind-proxy &
TUSD_PID=$!

echo -e "${YELLOW}Starting static-web-server (download server) on port 8787...${NC}"
# Run static-web-server in background with compression and CORS
static-web-server --port 8787 --root ./files --compression gzip &
SWS_PID=$!

echo -e "${GREEN}Both services started successfully!${NC}"
echo "tusd PID: $TUSD_PID"
echo "static-web-server PID: $SWS_PID"
echo ""
echo -e "${YELLOW}Press Ctrl+C to stop both services${NC}"

# Wait for both processes
wait $TUSD_PID $SWS_PID