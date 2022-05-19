#!/bin/bash
DOCKER_REGISTRY=qoutland/flask-app
DOCKER_TAG=latest

# Build and push docker image
docker build -t $DOCKER_REGISTRY:$DOCKER_TAG .
docker push $DOCKER_REGISTRY:$DOCKER_TAG