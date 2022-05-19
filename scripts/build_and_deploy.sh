#!/bin/bash
CLUSTER_NAME=flask-app-cluster
SERVICE_NAME=flask-app-service
DOCKER_REGISTRY=qoutland/flask-app
DOCKER_TAG=latest

# Build and push docker image
docker build -t $DOCKER_REGISTRY:$DOCKER_TAG .
docker push $DOCKER_REGISTRY:$DOCKER_TAG

# Deploy new docker image
aws ecs update-service --force-new-deployment --cluster $CLUSTER_NAME --service $SERVICE_NAME