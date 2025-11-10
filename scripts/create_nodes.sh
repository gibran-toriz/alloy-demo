#!/bin/bash

# Prompt user for the number of POS and Server nodes to create
read -p "Enter the number of POS nodes to create: " NUM_POS
read -p "Enter the number of Server nodes to create: " NUM_SERVER

# Define the central point
CENTER_LAT=19.45043988684875
CENTER_LONG=-99.21741412002501
MAX_DISTANCE_KM=100

# Function to generate random latitude and longitude within the radius
random_lat_long() {
  local radius_in_degrees=$(echo "$MAX_DISTANCE_KM / 111" | bc -l)
  local u=$(awk -v seed=$RANDOM 'BEGIN { srand(seed); print rand() }')
  local v=$(awk -v seed=$RANDOM 'BEGIN { srand(seed); print rand() }')
  local w=$(echo "$radius_in_degrees * sqrt($u)" | bc -l)
  local t=$(echo "2 * 3.14159265359 * $v" | bc -l)
  local x=$(echo "$w * c($t)" | bc -l)
  local y=$(echo "$w * s($t)" | bc -l)
  local new_lat=$(echo "$CENTER_LAT + $x" | bc -l)
  local new_long=$(echo "$CENTER_LONG + $y / c($CENTER_LAT * 3.14159265359 / 180)" | bc -l)
  echo "$new_lat $new_long"
}

# Function to check if a port is available
is_port_available() {
  local port=$1
  if lsof -i :$port >/dev/null 2>&1; then
    echo 0  # Port is in use
  else
    echo 1  # Port is available
  fi
}

# Function to find the next available port
find_next_available_port() {
  local start_port=$1
  while [ $(is_port_available $start_port) -eq 0 ]; do
    start_port=$((start_port + 1))
  done
  echo $start_port
}

# Function to get the next available ID for a container type
get_next_id() {
  local prefix=$1
  local existing_ids=$(docker ps -a --filter "name=${prefix}" --format "{{.Names}}" | grep -o "[0-9]*$" | sort -n)
  if [ -z "$existing_ids" ]; then
    echo 1
  else
    local last_id=$(echo "$existing_ids" | tail -n 1)
    echo $((last_id + 1))
  fi
}

# Create POS nodes
for ((i=1; i<=NUM_POS; i++)); do
  read LAT LONG <<< $(random_lat_long)
  BRAND=$(shuf -e retail acme -n 1)
  NEXT_ID=$(get_next_id "pos")
  docker run -d --name pos${NEXT_ID} \
    -e NODE_TYPE=pos \
    -e REGION=region${NEXT_ID} \
    -e LOCATION=store-${NEXT_ID} \
    -e BRAND=$BRAND \
    -e PROBLEM_MODE=healthy \
    -e LATITUDE=$LAT \
    -e LONGITUDE=$LONG \
    -p 930${NEXT_ID}:9300 \
    -p 1230${NEXT_ID}:12345 \
    --network alloy-demo_alloy_net \
    --volume /tmp/pos-logs:/var/log/hostlogs \
    alloy-demo-node:pos
done

# Create Server nodes
for ((i=1; i<=NUM_SERVER; i++)); do
  BRAND=$(shuf -e AIX acme -n 1)
  NEXT_ID=$(get_next_id "server")
  docker run -d --name server${NEXT_ID} \
    -e NODE_TYPE=server \
    -e REGION=region${NEXT_ID} \
    -e LOCATION=store-${NEXT_ID} \
    -e BRAND=$BRAND \
    -e PROBLEM_MODE=healthy \
    -e NODE_NAME=Server-${NEXT_ID} \
    -p 960${NEXT_ID}:9600 \
    -p 961${NEXT_ID}:9610 \
    -p 1260${NEXT_ID}:12345 \
    --network alloy-demo_alloy_net \
    --volume /tmp/server-logs:/var/log/hostlogs \
    alloy-demo-node:server
done

echo "Nodes created successfully."
