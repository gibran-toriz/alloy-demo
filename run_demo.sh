# Go to the directory where the script is located
cd /Users/gibrantoriz/CascadeProjects/alloy-demo

# Stop all running containers and remove them
docker-compose down
docker ps -a --filter "ancestor=alloy-demo-node:server" --filter "ancestor=alloy-demo-node:switch" --filter "ancestor=alloy-demo-node:router" --filter "ancestor=alloy-demo-node:pos" -q | xargs -r docker rm -f

# Create the Alloy demo network
#docker network create alloy-demo_alloy_net

# Start the stack
#./build_node_images.sh
docker-compose up -d 
sleep 10  # Wait for 10 seconds to ensure the stack is fully initialized

# Remove the logs 
 rm -rf /tmp/pos-logs/pos-core.log****

# Create the tmp directory for logs
./generate_test_logs.sh


# Define the central point
CENTER_LAT=19.45043988684875
CENTER_LONG=-99.21741412002501
MAX_DISTANCE_KM=500

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

# Start the Alloy demo nodes
## Pos nodes
for i in {1..5}; do
  read LAT LONG <<< $(random_lat_long)
  BRAND=$(shuf -e retail acme -n 1)
  docker run -d --name pos$i \
    -e NODE_TYPE=pos \
    -e REGION=region$i \
    -e LOCATION=store-$i \
    -e BRAND=$BRAND \
    -e PROBLEM_MODE=healthy \
    -e LATITUDE=$LAT \
    -e LONGITUDE=$LONG \
    -p 930$i:9300 \
    -p 1230$i:12345 \
    --network alloy-demo_alloy_net \
    --volume /tmp/pos-logs:/var/log/hostlogs \
    alloy-demo-node:pos
done

## Server nodes
for i in {1..5}; do
  BRAND=$(shuf -e AIX acme -n 1)
  docker run -d --name server$i \
    -e NODE_TYPE=server \
    -e REGION=region$i \
    -e LOCATION=store-$i \
    -e BRAND=$BRAND \
    -e PROBLEM_MODE=healthy \
    -e NODE_NAME=Server-$i \
    -p 960$i:9600 \
    -p 961$i:9610 \
    -p 1260$i:12345 \
    --network alloy-demo_alloy_net \
    --volume /tmp/server-logs:/var/log/hostlogs \
    alloy-demo-node:server
done

