#!/bin/bash
set -e

echo "Building patched skonadesk hbbs image..."
docker build -f Dockerfile.skonadesk -t skonadesk-hbbs:latest .
echo "Done. Image skonadesk-hbbs:latest is ready."
echo "You can now run: cd /srv/skonadesk && docker compose up -d --build"
