# Grafana Alloy Observability Stack - POC

A comprehensive Proof of Concept (POC) demonstrating a distributed observability stack using Grafana Alloy, Mimir, Loki, and dynamic node creation, orchestrated with Docker Compose.

## 🎯 Overview

This POC simulates a distributed retail infrastructure with dynamic point-of-sale (POS) systems and servers, providing real-time observability through metrics and logs aggregation.

### Key Components

**Observability Stack:**
- **Grafana Alloy**: Telemetry collection agent
- **Mimir**: Time-series metrics storage (Prometheus-compatible)
- **Loki**: Log aggregation and storage
- **Grafana**: Unified visualization dashboard

**Infrastructure Services:**
- **RabbitMQ**: Message broker for event streaming
- **FastAPI**: REST API for network connectivity data
- **iw-Robot**: Process automation framework
- **Custom Exporters**: Network connections and custom metrics

**Dynamic Nodes:**
- **POS Nodes**: Retail point-of-sale systems with transaction metrics
- **Server Nodes**: Backend servers with system metrics
- Geographic distribution simulation (configurable radius from center point)

## 🚀 Quick Start

For detailed setup instructions, please refer to **[SETUP_GUIDE.md](SETUP_GUIDE.md)**.

### Basic Usage

```bash
# 1. Start the base stack
./run_demo.sh

# 2. Create dynamic nodes (e.g., 3 POS + 2 Servers)
echo -e "3\n2" | ./scripts/create_nodes.sh

# 3. Access Grafana
# Open http://localhost:3000 (admin/admin)
```

## 📊 Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         Grafana UI                          │
│                    (Visualization Layer)                    │
└────────────────┬───────────────────────┬────────────────────┘
                 │                       │
        ┌────────▼────────┐     ┌───────▼────────┐
        │      Mimir      │     │      Loki      │
        │   (Metrics DB)  │     │    (Logs DB)   │
        └────────▲────────┘     └───────▲────────┘
                 │                       │
        ┌────────┴───────────────────────┴────────┐
        │          Grafana Alloy Central          │
        │        (Telemetry Collection)           │
        └────────▲───────────────────────▲────────┘
                 │                       │
     ┌───────────┴───────────┬───────────┴──────────┐
     │                       │                      │
┌────▼─────┐         ┌──────▼──────┐        ┌─────▼─────┐
│POS Nodes │         │   Servers   │        │ Exporters │
│ (Dynamic)│         │  (Dynamic)  │        │  (Static) │
└──────────┘         └─────────────┘        └───────────┘
```

## 🏗️ Project Structure

```
alloy-demo/
├── configs/                  # Alloy configuration files per node type
│   ├── alloy-central.river  # Central Alloy collector config
│   ├── pos.river            # POS node configuration
│   ├── server.river         # Server node configuration
│   └── router.river         # Router node configuration
├── config/                  # Application configuration files
│   ├── mimir-config.yaml    # Mimir configuration
│   ├── rabbitmq.conf        # RabbitMQ configuration
│   ├── rabbitmq-definitions.json
│   └── supervisord.conf     # Supervisor configuration
├── scripts/                 # Utility scripts
│   ├── create_nodes.sh      # Dynamic node creation script
│   ├── destroy_demo.sh      # Complete cleanup script
│   ├── generate_pos_logs.py # Log generation
│   └── entrypoint.sh        # Docker entrypoint
├── docs/                    # Documentation
│   ├── METRICS_REFERENCE.md
│   └── NOTES.md
├── custom_exporters/        # Custom metrics exporters
├── grafana/                 # Grafana dashboards and datasources
│   └── provisioning/
│       ├── dashboards/      # Pre-configured dashboards
│       ├── datasources/     # Mimir and Loki datasources
│       └── alerting/        # Alert rules and contact points
├── docker-compose.yaml      # Main services orchestration
├── Dockerfile               # Node image build definition
├── run_demo.sh             # POC initialization script
├── create_nodes.sh         # Dynamic node creation script
├── mimir-config.yaml       # Mimir configuration
└── SETUP_GUIDE.md          # Detailed setup instructions
```

## 🎨 Features

- **Dynamic Node Creation**: Spawn POS and Server nodes on-demand with unique configurations
- **Geographic Simulation**: Nodes are assigned random coordinates within a configurable radius
- **Auto-scaling Metrics**: Each node exports custom metrics (transactions, inventory, CPU, memory)
- **Log Aggregation**: Centralized log collection from all nodes
- **Pre-configured Dashboards**: Ready-to-use Grafana dashboards for infrastructure monitoring
- **Alerting**: Built-in alert rules with webhook notifications
- **Network Topology**: Simulated network devices (routers, switches)

## 📈 Metrics & Monitoring

Each POS node exposes:
- `pos_transactions_total`: Total transaction count
- `pos_amount_total`: Total sales amount
- `pos_inventory_items`: Current inventory levels
- `pos_cpu_usage`: CPU utilization
- `pos_memory_usage_bytes`: Memory consumption

Server nodes provide standard system metrics via built-in exporters.

## 🔗 Key Endpoints

| Service | URL | Description |
|---------|-----|-------------|
| Grafana | http://localhost:3000 | Main dashboard |
| Loki | http://localhost:3100 | Log queries |
| Mimir | http://localhost:9009 | Metrics ingestion |
| RabbitMQ | http://localhost:15672 | Message queue UI |
| FastAPI | http://localhost:8000/docs | API documentation |

## 📚 Documentation

- **[SETUP_GUIDE.md](SETUP_GUIDE.md)** - Complete setup and usage guide
- **[METRICS_REFERENCE.md](METRICS_REFERENCE.md)** - Metrics catalog (if available)
- **[ALLOY_DEMO_OPERATIONS.md](ALLOY_DEMO_OPERATIONS.md)** - Operations guide

## 🛠️ Requirements

- Docker 20.10+
- Docker Compose 2.0+
- Python 3.x
- Bash 4.0+
- 4GB+ available RAM
- 10GB+ disk space

## � Cleanup

To completely remove all POC components and free up resources:

```bash
./scripts/destroy_demo.sh
```

This will remove:
- All dynamic nodes (POS, Server, Switch, Router)
- All docker-compose services and volumes
- Temporary log files
- Background processes
- Docker network

## �🤝 Contributing

This is a proof of concept for demonstration purposes. Feel free to fork and adapt for your use case.

## 📝 License

See [LICENSE](LICENSE) file for details.

## 🐛 Troubleshooting

For troubleshooting steps and common issues, please refer to the **Troubleshooting** section in [SETUP_GUIDE.md](SETUP_GUIDE.md).

---

**Note**: This POC is designed for demonstration and testing purposes. Do not use in production environments without proper security hardening and configuration review.