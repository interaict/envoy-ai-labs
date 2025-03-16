#!/bin/bash

# Usage: ./env_setup.sh [envoy_config_file]
# Example: ./env_setup.sh envoy_header_routing_config.yml

# Set default Envoy config file if not provided
ENVOY_CONFIG=${1:-envoy_routing_config.yml}

# Stop and remove any existing containers
docker rm -f server1 server2 server3 server4 envoy 2>/dev/null

# Create a Docker network for all services
docker network create envoy-net 2>/dev/null || true

# Run service containers
docker run -d --name server-nginx --network envoy-net -p 8081:80 nginx
docker run -d --name server-httpbin --network envoy-net -p 8082:80 kennethreitz/httpbin
docker run -d --name server-echo --network envoy-net -p 8083:80 ealen/echo-server
docker run -d --name server-python --network envoy-net -p 8084:8000 python:3-alpine sh -c "python -m http.server 8000"

# Start Envoy with the specified configuration
echo "Starting Envoy with config file: $ENVOY_CONFIG"
docker run -d --name envoy \
  --network envoy-net \
  -v $(pwd)/$ENVOY_CONFIG:/etc/envoy/envoy.yaml \
  -p 10000:10000 \
  -p 9901:9901 \
  envoyproxy/envoy:v1.29-latest

# Show running containers
docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Ports}}"

echo "Environment setup complete. Containers and Envoy are running."
