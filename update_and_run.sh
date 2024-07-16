#!/bin/bash
sudo docker stop $(sudo docker ps -q)
git pull
docker build -t fooocus-api-pb .
sudo docker run --network host --gpus all -p 8888:8888 fooocus-api-pb
