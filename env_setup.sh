#!/bin/bash

# Usage: ./env_setup.sh [envoy_config_file]
# Example: ./env_setup.sh my_envoy_config.yml

# Set default Envoy config file if not provided
ENVOY_CONFIG=${1:-envoy_routing_config.yml}

# Stop and remove any existing containers
docker rm -f server1 server2 server3 server4 2>/dev/null

# Run new containers
docker run -d --name server1 -p 8081:80 nginx
docker run -d --name server2 -p 8082:80 kennethreitz/httpbin
docker run -d --name server3 -p 8083:80 ealen/echo-server
docker run -d --name server4 -p 8084:8000 python:3-alpine sh -c "python -m http.server 8000"

# Show running containers
docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Ports}}"

# Start Envoy with the specified configuration
echo "Starting Envoy with config file: $ENVOY_CONFIG"
/usr/local/bin/envoy -c "$ENVOY_CONFIG" --log-level debug &

echo "Environment setup complete. Containers and Envoy are running."
