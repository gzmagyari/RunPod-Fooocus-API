#!/bin/bash

# Pull the latest code from the repository
git pull

# Build the Docker image
docker build -t fooocus-api-pb .

# Check if the user is logged in to Docker
if ! docker info >/dev/null 2>&1; then
    echo "Docker login required"
    docker login
else
    echo "Already logged in to Docker"
fi

# Check if the image is already tagged
IMAGE_TAG="gzmagyari/fooocus-api-pb:local"
docker tag fooocus-api-pb $IMAGE_TAG

# Push the Docker image to Docker Hub
docker push $IMAGE_TAG
