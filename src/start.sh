#!/bin/bash
echo "Worker Initiated"

echo "Starting Fooocus API"
cd /workspace

mkdir -p /temp/fooocus_output1
mkdir -p /temp/fooocus_temp1
mkdir -p /temp/cache1
mkdir -p /temp/fooocus_output2
mkdir -p /temp/fooocus_temp2
mkdir -p /temp/cache2

#python launch.py --disable-in-browser --always-gpu --disable-offload-from-vram --listen 0.0.0.0 --port 8887 --output-path /temp/fooocus_output1 --temp-path /temp/fooocus_temp1 --cache-path /temp/cache1 & # You can add more Fooocus flags here to optimize performance for your workers, see https://github.com/lllyasviel/Fooocus?tab=readme-ov-file#all-cmd-flags
#python launch.py --disable-in-browser --always-gpu --disable-offload-from-vram --listen 0.0.0.0 --port 4447 --output-path /temp/fooocus_output2 --temp-path /temp/fooocus_temp2 --cache-path /temp/cache2 &

echo "Starting RunPod Handler"
cd /
python -u /multi_handler.py --rp_serve_api --rp_api_host='0.0.0.0' --rp_api_port 8000 --rp_api_concurrency 2