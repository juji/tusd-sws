#!/bin/bash

echo "Starting static-web-server (rust) server on port 8787..."
static-web-server --port 8787 --root ./files
