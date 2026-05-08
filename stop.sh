#!/bin/bash
# stop.sh
# Stops and cleans up the entire stack

echo "Stopping stack..."

echo "Stopping port forward..."
pkill -f "kubectl port-forward" || true

echo "Stopping Prometheus and Grafana..."
docker compose -f observability/docker-compose.yml down

echo "Stopping Kubernetes resources..."
kubectl delete -f k8s/

echo "Stopping minikube..."
minikube stop

echo "Stack stopped cleanly"