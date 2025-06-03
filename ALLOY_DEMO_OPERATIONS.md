# Alloy Retail Observability Demo: Operations & Knowledge Guide

This document captures the essential knowledge, setup, and operational procedures for the Alloy-based scalable observability demo for a large retailer scenario. It covers architecture, dynamic node management, troubleshooting, and key metrics.

---

## Architecture Overview

- **Central Stack:**
  - **Loki**: Centralized log aggregation (port 3100)
  - **Mimir**: Centralized metrics storage (ports 9009, 9095)
  - **Grafana**: Visualization and dashboards (port 3000)
- **Node Types:**
  - **Router**: Network device monitoring (port 9400, UI: 12348)
  - **Switch**: Network switching infrastructure (port 9401, UI: 12350)
  - **POS**: Point of Sale terminals (port 9300, UI: 12349)
  - **Server**: Application servers (port 9100, UI: 12351)
- **Key Features:**
  - Each node runs its own Alloy agent and relevant exporter(s)
  - Node metadata (region, location, type, device, brand) set via environment variables
  - Problem mode simulation via `PROBLEM_MODE` environment variable
  - Log collection from `/var/log/hostlogs/` mounted directory
  - All nodes report to the central stack

---

## Quickstart: Running the Demo

### 1. Build the Node Images

```bash
# Make the build script executable
chmod +x build_node_images.sh

# Build all node images
./build_node_images.sh
```

### 2. Generate Test Logs

```bash
# Make the log generation script executable
chmod +x generate_test_logs.sh

# Generate sample log files in /tmp/*-logs directories
./generate_test_logs.sh
```

### 3. Start the Central Observability Stack

```bash
docker compose up -d loki mimir grafana
```

Wait a minute for the services to initialize, then access:
- Grafana: http://localhost:3000 (admin/admin)
- Loki API: http://localhost:3100
- Mimir API: http://localhost:9009

### 4. Start the Node Containers

#### Start a Router Node:
```bash
docker run -d --name router1 \
  -e NODE_TYPE=router \
  -e REGION=region1 \
  -e LOCATION=datacenter-1 \
  -e DEVICE=core-router-01 \
  -e DEVICE_TYPE=cisco-nexus \
  -e PROBLEM_MODE=problem \
  -p 9400:9400 \
  -p 12348:12345 \
  --network alloy-demo_alloy_net \
  --volume /tmp/router-logs:/var/log/hostlogs \
  alloy-demo-node:router
```

#### Start a Switch Node:
```bash
docker run -d --name switch1 \
  -e NODE_TYPE=switch \
  -e REGION=region1 \
  -e LOCATION=datacenter-1 \
  -e DEVICE=access-switch-01 \
  -e DEVICE_TYPE=cisco-catalyst \
  -e PROBLEM_MODE=healthy \
  -p 9401:9401 \
  -p 12350:12345 \
  --network alloy-demo_alloy_net \
  --volume /tmp/switch-logs:/var/log/hostlogs \
  alloy-demo-node:switch
```

#### Start a POS Node:
```bash
docker run -d --name pos1 \
  -e NODE_TYPE=pos \
  -e REGION=region1 \
  -e LOCATION=store-1 \
  -e BRAND=acme \
  -e PROBLEM_MODE=problem \
  -p 9300:9300 \
  -p 12349:12345 \
  --network alloy-demo_alloy_net \
  --volume /tmp/pos-logs:/var/log/hostlogs \
  alloy-demo-node:pos
```

#### Start a Server Node:
```bash
docker run -d --name server1 \
  -e NODE_TYPE=server \
  -e REGION=region1 \
  -e LOCATION=datacenter-1 \
  -e HOSTNAME=app-server-01 \
  -e BRAND=acme \
  -e PROBLEM_MODE=healthy \
  -p 9100:9100 \
  -p 12351:12345 \
  --network alloy-demo_alloy_net \
  --volume /tmp/server-logs:/var/log/hostlogs \
  alloy-demo-node:server
```

### 5. Verify Log Collection

Check logs from the command line:

```bash
# Check router logs
curl -s -G --data-urlencode 'query={node_type="router"}' http://localhost:3100/loki/api/v1/query_range | jq

# Check switch logs
curl -s -G --data-urlencode 'query={node_type="switch"}' http://localhost:3100/loki/api/v1/query_range | jq

# Check POS logs
curl -s -G --data-urlencode 'query={node_type="pos"}' http://localhost:3100/loki/api/v1/query_range | jq

# Check server logs
curl -s -G --data-urlencode 'query={node_type="server"}' http://localhost:3100/loki/api/v1/query_range | jq
```

### 6. View Metrics and Logs in Grafana

1. Open Grafana at http://localhost:3000
2. Log in with admin/admin
3. Go to "Explore" in the left sidebar
4. Select the appropriate data source:
   - For metrics: Select "Mimir"
   - For logs: Select "Loki"

Example queries:
- `count by(instance) (up)` - View all running instances
- `node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes` - Memory usage
- `rate(node_network_receive_bytes_total[5m])` - Network receive rate
- `{node_type=~"router|switch"} |~ "error|warn|fail"` - Error logs from network devices

## Node Management

### Adding a New Node

To add a new node to the demo:

1. Create a new configuration file in `configs/` if needed
2. Build the node image:
   ```bash
   docker build -t alloy-demo-node:<node-type> --build-arg NODE_TYPE=<node-type> .
   ```
3. Run the container with appropriate environment variables

### Dynamic Node Configuration

Each node is configured via environment variables:

- `NODE_TYPE`: Type of node (router, switch, pos, server)
- `REGION`: Geographic region (e.g., region1, region2)
- `LOCATION`: Physical location (e.g., datacenter-1, store-1)
- `DEVICE`: Device identifier (for network devices)
- `DEVICE_TYPE`: Device type (e.g., cisco-nexus, cisco-catalyst)
- `BRAND`: Brand/organization (e.g., acme)
- `PROBLEM_MODE`: Set to "problem" to simulate issues (default: "healthy")

### Updating Node Configuration

To update a node's configuration:

1. Stop and remove the existing container:
   ```bash
   docker stop <container_name>
   docker rm <container_name>
   ```
2. Run a new container with updated environment variables

## Log Collection

### Log File Locations

- Router: `/var/log/hostlogs/network-core.log`
- Switch: `/var/log/hostlogs/switch-core.log`
- POS: `/var/log/hostlogs/pos-core.log`
- Server: `/var/log/hostlogs/server-core.log`

### Log Format

Logs should be in a standard format with timestamp and log level:
```
2025-06-03T21:20:36.134560000Z [INFO] Sample log message
```

### Adding Custom Logs

To add custom logs to a node:

1. Ensure the log directory is mounted to the container
2. Write logs to the appropriate log file in the mounted directory
3. The Alloy agent will automatically pick up and forward new log entries

## Troubleshooting

### Common Issues

1. **No logs appearing in Loki**
   - Check if the log files exist in the mounted directory
   - Verify the container has read permissions on the log files
   - Check Alloy logs: `docker logs <container_name>`
   - Look for Loki errors in Alloy logs

2. **Metrics not showing in Mimir**
   - Check if the exporter is running: `curl http://localhost:<EXPORTER_PORT>/metrics`
   - Verify Alloy is scraping the exporter
   - Check Alloy's targets page at `http://<node-ip>:<alloy-port>/targets`

3. **Container fails to start**
   - Check container logs: `docker logs <container_name>`
   - Verify all required environment variables are set
   - Check for port conflicts

4. **Problem mode not working**
   - Verify `PROBLEM_MODE=problem` is set in the environment
   - Check the exporter logs for errors
   - Restart the container after changing environment variables

### Useful Commands

```bash
# View running containers
docker ps

# View container logs
docker logs <container_name>

# View Alloy metrics
docker exec <container_name> wget -qO- http://localhost:12345/metrics

# Generate more test logs
./generate_test_logs.sh

# Rebuild and restart a node
docker stop <container_name>
docker rm <container_name>
# Then run the appropriate docker run command again
```

## Monitoring and Alerting

### Key Metrics to Monitor

1. **Router/Switch Metrics**
   - `network_device_up` - Device status (0=down, 1=up)
   - `network_device_cpu_usage` - CPU usage percentage
   - `network_device_memory_usage` - Memory usage percentage
   - `network_device_packet_loss` - Network packet loss percentage
   - `network_device_ports_up` - Number of active ports

2. **Server Metrics**
   - `node_cpu_seconds_total` - CPU usage
   - `node_memory_MemAvailable_bytes` - Available memory
   - `node_disk_io_time_seconds_total` - Disk I/O
   - `node_network_receive_bytes_total` - Network traffic

3. **POS Metrics**
   - `pos_transaction_total` - Total transactions
   - `pos_transaction_duration_seconds` - Transaction duration
   - `pos_payment_errors_total` - Payment errors
   - `pos_inventory_items` - Inventory levels

### Example Alert Rules

```yaml
groups:
- name: network.rules
  rules:
  - alert: NetworkDeviceDown
    expr: network_device_up == 0
    for: 5m
    labels:
      severity: critical
    annotations:
      summary: "Network device {{ $labels.device }} is down"
      description: "The network device {{ $labels.device }} has been down for more than 5 minutes"

  - alert: HighPacketLoss
    expr: network_device_packet_loss > 5
    for: 5m
    labels:
      severity: warning
    annotations:
      summary: "High packet loss on {{ $labels.device }}"
      description: "Packet loss on {{ $labels.device }} is {{ $value }}% (over 5% threshold)"
```

### 2. Start Example Static Nodes
```sh
docker compose up -d alloy_region1_server alloy_region1_pos alloy_region1_router alloy_region1_switch
```
(Or any subset you wish.)

### 3. Dynamically Add a Node (using the template)
For a POS node:
```sh
docker compose run -d --name node1 \
  -e NODE_TYPE=pos \
  -e REGION=region3 \
  -e LOCATION=store-3 \
  -e PROBLEM_MODE=healthy \
  -e BRAND=brand2 \
  -p 9500:9300 \
  alloy_node_template
```
For a router node:
```sh
docker compose run -d --name node2 \
  -e NODE_TYPE=router \
  -e DEVICE_TYPE=router \
  -e DEVICE=router-3 \
  -e REGION=region3 \
  -e LOCATION=store-3 \
  -e PROBLEM_MODE=healthy \
  -p 9600:9400 \
  alloy_node_template
```
(Adjust `--name`, env vars, and ports as needed for your scenario.)

### 4. Stop and Remove Nodes
To stop a node:
```sh
docker compose stop node1
```
To remove a node:
```sh
docker compose rm -f node1
```

---

## Dynamic Node Template
- The `alloy_node_template` service in `docker-compose.yaml` allows you to create new nodes on the fly with custom metadata and port mappings.
- Only the correct exporter and Alloy agent are started per node, thanks to the dynamic `entrypoint.sh` script.

---

## Troubleshooting
- **Alloy Fails to Start:**
  - Check `/tmp/alloy_stderr.log` in the container for errors:
    ```sh
    docker exec <container_name> tail -50 /tmp/alloy_stderr.log
    ```
  - Common issues: missing env vars, config errors, network issues to Loki/Mimir.
- **Exporter Not Running:**
  - Ensure the correct `NODE_TYPE`, `DEVICE_TYPE`, and other env vars are set.
- **Metrics/Logs Not Appearing in Grafana:**
  - Check that the node is running and reporting to the correct central stack endpoints.

---

## Metrics & Labels Reference
See `METRICS_REFERENCE.md` for a full list of all metrics, labels, and example queries for each exporter.

---

## Key Files
- `docker-compose.yaml`: Service definitions for central stack and nodes
- `entrypoint.sh`: Dynamically generates `supervisord.conf` for each node
- `supervisord.conf`: Template for exporter/Alloy process management
- `config.river`: Alloy configuration, uses env vars for all labels and targets
- `custom_exporters/`: All custom exporter scripts
- `grafana/provisioning/dashboards/`: Dashboards for Grafana

---

## Best Practices
- Always rebuild the image after changing `config.river` or exporter scripts:
  ```sh
  docker compose build alloy_node_template
  ```
- Use unique port mappings for each dynamic node to avoid conflicts.
- Use meaningful names and env vars for each node to make dashboards and logs easy to filter.
- To simulate problems, set `PROBLEM_MODE=problem` on any node.

---

## Example: Full Demo Workflow
1. Start the stack:
   ```sh
   docker compose up -d loki mimir grafana
   ```
2. Add a healthy POS node:
   ```sh
   docker compose run -d --name pos-demo \
     -e NODE_TYPE=pos \
     -e REGION=us-east \
     -e LOCATION=store-101 \
     -e BRAND=brand1 \
     -e PROBLEM_MODE=healthy \
     -p 9311:9300 alloy_node_template
   ```
3. Add a problematic router:
   ```sh
   docker compose run -d --name router-demo \
     -e NODE_TYPE=router \
     -e DEVICE_TYPE=router \
     -e DEVICE=router-99 \
     -e REGION=us-east \
     -e LOCATION=store-101 \
     -e PROBLEM_MODE=problem \
     -p 9412:9400 alloy_node_template
   ```
4. View dashboards at [http://localhost:3000](http://localhost:3000) (admin/admin)
5. Stop and remove nodes as needed.

---

## Further Reading
- See `METRICS_REFERENCE.md` for all metric/label details and example PromQL queries.
- See `README.md` for project background and architecture.

---

*This document is auto-generated to capture the operational knowledge and best practices for running and extending the Alloy Retail Observability Demo.*
