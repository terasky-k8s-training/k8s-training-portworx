#!/bin/bash

# Set the namespace and service name
NAMESPACE="kube-system"
SERVICE_NAME="portworx-api"
TIMEOUT_SECONDS=180  # 3 minutes timeout

# Function to check if the LoadBalancer service has an external IP
check_load_balancer() {
  EXTERNAL_IP=$(kubectl get svc $SERVICE_NAME -n $NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
}

# Start time
START_TIME=$(date +%s)
TIME_ELAPSED=0

# Wait for the LoadBalancer service to be assigned an external IP or hostname
echo "Waiting for LoadBalancer service to be ready..."
while [ $TIME_ELAPSED -lt $TIMEOUT_SECONDS ]; do
  check_load_balancer
  if [ -n "$EXTERNAL_IP" ]; then
    echo "LoadBalancer service is ready. External Hostname: $EXTERNAL_IP"
    exit 0
  else
    echo "LoadBalancer service is not ready yet. Waiting..."
    sleep 15
    CURRENT_TIME=$(date +%s)
    TIME_ELAPSED=$((CURRENT_TIME - START_TIME))
  fi
done

# Timeout reached
echo "Timeout reached. LoadBalancer service is not ready after $TIMEOUT_SECONDS seconds."
exit 1
