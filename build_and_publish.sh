#!/bin/bash
git pull
docker build -t fooocus-api-pb .
#docker login
#docker tag myimage gzmagyari/fooocus-api-pb:latest
docker push gzmagyari/fooocus-api-pb:latest
