#!/bin/bash
# start.sh
# Starts the complete ml-salary-predictor stack with a single command.
# Includes: Kubernetes (API), Prometheus, Grafana

set -e  # stop script if any command fails

echo "Starting ml-salary-predictor stack..."

# -- 1. MINIKUBE --
echo "Starting minikube..."
minikube start

# -- 2. KUBERNETES MANIFESTS --
echo "Applying Kubernetes manifests..."
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml

# -- 3. WAIT FOR PODS TO BE READY --
echo "Waiting for pods to be ready..."
sleep 10
kubectl wait --for=condition=ready pod \
  -l app=salary-predictor \
  --timeout=120s

# -- 4. PORT FORWARD --
echo "Setting up port forwarding..."
kubectl port-forward service/salary-predictor-service 8080:80 &
sleep 3

# -- 5. OBSERVABILITY --
echo "Starting Prometheus and Grafana..."
docker compose -f observability/docker-compose.yml up -d

# -- 6. URLS --
echo ""
echo "Stack is up and running:"
echo "  API:        http://localhost:8080"
echo "  Prometheus: http://localhost:9090"
echo "  Grafana:    http://localhost:3000 (admin/devops123)"
echo ""
echo "To stop everything: ./stop.sh"