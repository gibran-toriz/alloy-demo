# Go to the directory where the script is located
cd "$(dirname "$0")"

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

# Generate test logs
nohup python3 generate_pos_logs.py &

# Note: Use create_nodes.sh to dynamically create POS and Server nodes.

