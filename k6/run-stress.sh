#!/bin/bash

# Get the current service IP
SERVICE_IP=$(kubectl get service devops-store-service -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

if [ -z "$SERVICE_IP" ]; then
    echo "Error: Could not get service IP. Make sure:"
    echo "1. You're connected to the cluster"
    echo "2. The service exists and has an external IP"
    exit 1
fi

echo "Running stress test against: $SERVICE_IP"
k6 run -e SERVICE_IP=$SERVICE_IP stress.js
