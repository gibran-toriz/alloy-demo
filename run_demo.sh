# Stop all running containers and remove them
docker-compose down -v
docker ps -a --filter "ancestor=alloy-demo-node:server" --filter "ancestor=alloy-demo-node:switch" --filter "ancestor=alloy-demo-node:router" --filter "ancestor=alloy-demo-node:pos" -q | xargs -r docker rm -f

# Create the Alloy demo network
docker network create alloy-demo_alloy_net

# Start the stack
./build_node_images.sh
docker-compose up -d 

# Create the tmp directory for logs
./generate_test_logs.sh


# Start the Alloy demo nodes
docker run -d --name pos1 \
  -e NODE_TYPE=pos \
  -e REGION=region1 \
  -e LOCATION=store-1 \
  -e BRAND=acme \
  -e PROBLEM_MODE=healthy \
  -p 9300:9300 \
  -p 12349:12345 \
  --network alloy-demo_alloy_net \
  --volume /tmp/pos-logs:/var/log/hostlogs \
  alloy-demo-node:pos

docker run -d --name router1 \
  -e NODE_TYPE=router \
  -e REGION=region1 \
  -e LOCATION=datacenter-1 \
  -e DEVICE=core-router-01 \
  -e DEVICE_TYPE=cisco-nexus \
  -e PROBLEM_MODE=healthy \
  -p 9400:9400 \
  -p 12348:12345 \
  --network alloy-demo_alloy_net \
  --volume /tmp/router-logs:/var/log/hostlogs \
  alloy-demo-node:router

docker run -d --name switch1 \
  -e NODE_TYPE=switch \
  -e REGION=region1 \
  -e LOCATION=datacenter-1 \
  -e DEVICE=access-switch-01 \
  -e DEVICE_TYPE=cisco-catalyst \
  -e PROBLEM_MODE=healthy \
  -p 9500:9500 \
  -p 12350:12345 \
  --network alloy-demo_alloy_net \
  --volume /tmp/switch-logs:/var/log/hostlogs \
  alloy-demo-node:switch

docker run -d --name server1 \
  -e NODE_TYPE=server \
  -e REGION=region1 \
  -e LOCATION=datacenter-1 \
  -e HOSTNAME=app-server-01 \
  -e BRAND=acme \
  -e PROBLEM_MODE=healthy \
  -p 9600:9600 \
  -p 12351:12345 \
  --network alloy-demo_alloy_net \
  --volume /tmp/server-logs:/var/log/hostlogs \
  alloy-demo-node:server

