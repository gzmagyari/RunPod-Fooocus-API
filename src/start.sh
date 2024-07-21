#!/bin/bash
echo "Worker Initiated"

echo "Starting Fooocus API"
cd /workspace
python launch.py --skip-pip --disable-in-browser --always-gpu --disable-offload-from-vram --port 8888 & # You can add more Fooocus flags here to optimize performance for your workers, see https://github.com/lllyasviel/Fooocus?tab=readme-ov-file#all-cmd-flags

echo "Starting RunPod Handler"
cd /
python -u /handler.py --rp_serve_api --rp_api_host='0.0.0.0' --rp_api_port 8000