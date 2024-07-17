#!/bin/bash
sudo docker stop $(sudo docker ps -q)
git pull
docker build -t fooocus-api-pb .
sudo docker run --network host --gpus all -p 8000:8000 fooocus-api-pb
