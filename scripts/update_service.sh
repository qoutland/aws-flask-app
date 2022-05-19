#!/bin/bash
# This script will perform a rolling update of the service

CLUSTER_NAME=flask-app-cluster
SERVICE_NAME=flask-app-service

aws ecs update-service --force-new-deployment --cluster $CLUSTER_NAME --service $SERVICE_NAME
