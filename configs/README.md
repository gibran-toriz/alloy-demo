# Alloy Configuration Files

This directory contains Alloy configuration files for different node types in the observability demo. Each file is tailored to a specific node type and includes only the necessary components for that node.

## Available Configurations

### `pos.river`
- **Node Type**: POS (Point of Sale) systems
- **Scrapes**: POS exporter metrics
- **Logs**: Collects POS application logs
- **Ports**: 9300 (POS Exporter)

### `server.river`
- **Node Type**: Server nodes
- **Scrapes**: Node exporter metrics
- **Logs**: System logs (via host mounts)
- **Ports**: 9100 (Node Exporter)

### `router.river`
- **Node Type**: Network routers
- **Scrapes**: Network device exporter metrics
- **Logs**: Router logs
- **Ports**: 9400 (Network Device Exporter)

### `switch.river`
- **Node Type**: Network switches
- **Scrapes**: Network device exporter metrics
- **Logs**: Switch logs
- **Ports**: 9401 (Network Device Exporter)

## Environment Variables Used

All configurations use the following environment variables for dynamic configuration:

- `REGION`: The region where the node is located (e.g., "region1", "region2")
- `LOCATION`: The specific location or store (e.g., "store-1", "store-2")
- `NODE_TYPE`: The type of node (pos, server, router, switch)
- `BRAND`: For POS nodes, the brand of the POS system
- `DEVICE`: For network devices, the device identifier
- `DEVICE_TYPE`: For network devices, the type of device (router, switch)
- `PROBLEM_MODE`: Set to "problem" to simulate issues (for demo purposes)

## How It Works

1. Each node type has its own dedicated configuration file that only includes the necessary components.
2. The Dockerfile uses build arguments to copy the appropriate config file based on the node type.
3. Environment variables are used to customize the configuration at runtime.
4. All metrics are sent to the central Mimir instance.
5. All logs are sent to the central Loki instance.

## Adding a New Node Type

1. Create a new `.river` file in this directory with the configuration for the new node type.
2. Update the Dockerfile to handle the new node type.
3. Update the docker-compose.yaml file to include the new node type with the appropriate build arguments.
4. Add the new node type to this README with documentation.
