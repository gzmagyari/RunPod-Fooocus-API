#!/bin/bash
echo "Worker Initiated"

echo "Starting Fooocus API"
cd /workspace
python launch.py --disable-in-browser --always-gpu --disable-offload-from-vram --port 8887 & # You can add more Fooocus flags here to optimize performance for your workers, see https://github.com/lllyasviel/Fooocus?tab=readme-ov-file#all-cmd-flags

echo "Starting RunPod Handler"
cd /
python -u /handler.py