# Grafana Alloy Observability POC

This project is a Proof of Concept (POC) demonstrating an observability stack using Grafana Alloy, Mimir, Loki, and custom exporters, all orchestrated with Docker Compose.

## Overview

The stack includes:
- **Grafana Alloy**: Collects metrics and logs.
- **Mimir**: Stores metrics (Prometheus-compatible).
- **Loki**: Stores logs.
- **Grafana**: Visualizes data from Mimir and Loki.
- **Node Exporter**: Exposes system metrics.
- **Custom Exporter**: A shell script (`custom_exporter.sh`) exposing a custom temperature metric.

## Prerequisites

- Docker
- Docker Compose

## Directory Structure

```
.alloy-server-example/
├── Dockerfile                # Builds the main 'alloy-lab' service image
├── docker-compose.yaml       # Orchestrates all services
├── config.river              # Grafana Alloy pipeline configuration
├── supervisord.conf          # Manages processes within the 'alloy-lab' container
├── custom_exporters/
│   └── custom_exporter.sh    # Script for custom metrics
├── hostlogs/
│   └── app.log               # Example log file collected by Alloy (must exist)
├── mimir-config.yaml         # Mimir configuration
└── README.md                 # This file
```

## Configuration Notes

- **Alloy Pipeline (`config.river`)**: Defines how metrics and logs are collected and forwarded.
  - Metrics from Node Exporter and the Custom Exporter are sent to Mimir.
  - Logs from `/var/log/hostlogs/app.log` (mounted from `./hostlogs/app.log` on the host) are sent to Loki.
- **Log Collection**: Currently, `loki.source.file` in `config.river` is configured to specifically target `app.log` due to an issue with wildcard matching (`*.log`) on this setup. If you need to collect from multiple log files or use wildcards, further investigation into Alloy's file discovery with Docker volumes on your OS might be needed.

## How to Run

1.  **Clone the Repository** (if applicable) or ensure you have all project files.

2.  **Prepare Log File**: Create the log directory and an initial log file if it doesn't exist. Alloy expects `/var/log/hostlogs/app.log` inside its container, which is mapped from `./hostlogs/app.log` on your host.
    ```bash
    mkdir -p hostlogs
    touch hostlogs/app.log
    echo "$(date) - Initial log entry for POC startup" >> hostlogs/app.log
    ```

3.  **Build and Start Services**: From the project's root directory, run:
    ```bash
    docker-compose up -d --build
    ```
    This will build the `alloy-lab` image and start all services in detached mode.

## Accessing Services & Verifying Data

-   **Grafana**: `http://localhost:3000`
    -   Credentials: `admin` / `admin` (you'll be prompted to change the password on first login).
    -   **Mimir Data (Metrics)**:
        -   Navigate to Explore (compass icon).
        -   Select the "Mimir" data source.
        -   Query for `custom_temperature` to see the custom metric.
        -   Query for `up{job="prometheus.scrape.custom_exporter"}` (should be `1`).
        -   Query for `up{job="prometheus.scrape.node_exporter"}` (should be `1`).
    -   **Loki Data (Logs)**:
        -   Navigate to Explore.
        -   Select the "Loki" data source.
        -   Query for `{job="example_logs"}` or `{filename="/var/log/hostlogs/app.log"}`.

-   **Node Exporter Metrics**: `http://localhost:9100/metrics` (directly from the exporter)
-   **Custom Exporter Metrics**: `http://localhost:9200/metrics` (directly from the exporter)

## Troubleshooting

-   **Alloy Logs**: To see Grafana Alloy's own logs (including debug information if `logging { level = "debug" ... }` is set in `config.river`):
    ```bash
    docker exec alloy-lab cat /tmp/alloy_stderr.log
    # or for stdout, though most debug info went to stderr in our case:
    # docker exec alloy-lab cat /tmp/alloy_stdout.log
    ```
    (These paths are defined in `supervisord.conf` for the `alloy` program).

-   **Other Container Logs**:
    ```bash
    docker logs <container_name>
    # Examples:
    # docker logs alloy-lab
    # docker logs loki
    # docker logs mimir
    # docker logs grafana
    ```

-   **Custom Exporter Not Working**: Ensure `nc` (netcat) is available in the `alloy-lab` container (it's installed via `Dockerfile`). Check `custom_exporter.sh` for issues.

-   **Log Collection Issues**: As noted, if `app.log` isn't being picked up, verify the path in `config.river` (`loki.source.file`) and ensure the `./hostlogs/app.log` file exists on the host before starting containers.

## Stopping the POC

To stop and remove all containers, networks, and volumes created by Docker Compose:
```bash
docker-compose down
```

If you want to remove volumes to clear stored Mimir/Loki data, you can use:
```bash
docker-compose down -v
```
