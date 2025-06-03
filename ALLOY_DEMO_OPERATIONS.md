# Alloy Retail Observability Demo: Operations & Knowledge Guide

This document captures the essential knowledge, setup, and operational procedures for the Alloy-based scalable observability demo for a large retailer scenario. It covers architecture, dynamic node management, troubleshooting, and key metrics.

---

## Architecture Overview

- **Central Stack:**
  - **Loki**: Centralized log aggregation
  - **Mimir**: Centralized metrics storage
  - **Grafana**: Visualization and dashboards
- **Nodes:**
  - Each node (server, POS, router, switch, custom) runs its own Alloy agent and relevant exporter(s)
  - Node metadata (region, location, type, device, brand, problem mode) is set via environment variables
  - All nodes report to the central stack
  - Nodes are defined as services in `docker-compose.yaml` or instantiated dynamically from a template

---

## Quickstart: Running the Demo

### 1. Start the Central Observability Stack
```sh
docker compose up -d loki mimir grafana
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
