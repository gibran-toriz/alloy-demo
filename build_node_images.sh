#!/bin/bash

# Build router image
echo "Building router image..."
docker build -t alloy-demo-node:router --build-arg NODE_TYPE=router .

# Build switch image
echo "Building switch image..."
docker build -t alloy-demo-node:switch --build-arg NODE_TYPE=switch .

# Build POS image
echo "Building POS image..."
docker build -t alloy-demo-node:pos --build-arg NODE_TYPE=pos .

# Build server image
echo "Building server image..."
docker build -t alloy-demo-node:server --build-arg NODE_TYPE=server .

echo "All images built successfully!"
