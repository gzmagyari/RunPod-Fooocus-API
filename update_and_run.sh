#!/bin/bash
git pull
sudo docker stop $(sudo docker ps -q)
docker build -t fooocus-api-pb .
sudo docker run --network host --gpus all -p 8000:8000 fooocus-api-pb
