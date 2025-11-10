# Setup Guide - Alloy Demo POC

## 📋 Prerequisites

- Docker & Docker Compose
- Python 3.x
- Git
- **iw-Robot 1.2.0** (automation framework) - See [iw-Robot Setup](#-iw-robot-setup-required) section below

## ⚠️ iw-Robot Setup

Before running the POC, you **must** set up iw-Robot manually. This is a critical component for the alerting and automation features.

### Step 1: Obtain iw-Robot

1. Download or obtain the **iw-Robot** distribution package (`.tar` file)
2. Extract the contents to get the `iw-robot` folder

### Step 2: Place iw-Robot in the Project

Copy the extracted `iw-robot` folder into the project's `iwRobot` directory:

```bash
# From your alloy-demo project root
cp -r /path/to/your/iw-robot ./iwRobot/
```

Your directory structure should look like:
```
alloy-demo/
├── iwRobot/
│   ├── iw-robot/          # ← The iw-Robot application folder
│   ├── resources/         # ← Already included in repo
│   └── Observabilidad.edn # ← Already included in repo
```

### Step 3: Copy Resources (if needed)

The `resources` folder is already included in the repository and contains:
- `startRAM.sh` - Script to start RAM simulator
- `stopRam.sh` - Script to stop RAM simulator  
- `restart_ram.py` - Python script to restart containers

If you need to update or verify these files, they're located at:
```bash
./iwRobot/resources/
```

### Step 4: Import Automation Workflow

Once iw-Robot is running (after `./run_demo.sh`), you need to import the automation workflow:

1. **Access iw-Robot UI**:
   - VNC: `vnc://localhost:5901` (use a VNC client)
   - Or via the iw-Robot interface on port 8050

2. **Import the workflow**:
   - Open iw-Robot application
   - Navigate to **Import** or **Load Workflow** option
   - Select the file: `./iwRobot/Observabilidad.edn`
   - This workflow monitors RabbitMQ alerts and manages container lifecycle

3. **Workflow Description**:
   The `Observabilidad.edn` workflow:
   - Monitors RabbitMQ queue for alerts
   - Automatically responds to infrastructure issues
   - Manages container restarts via Docker socket
   - Sends email notifications on critical events

### Step 5: Verify iw-Robot Integration

After starting the stack, verify iw-Robot is properly connected:

```bash
# Check iw-Robot container is running
docker logs iw-robot

# Verify Docker socket access (allows iw-Robot to manage containers)
docker exec iw-robot docker ps
```

### 📌 Important Notes

- The `iwRobot/iw-robot/` folder is **NOT tracked by git** (in `.gitignore`)
- You must provide this folder manually on each new clone
- The `resources/` folder and `Observabilidad.edn` are tracked and included
- iw-Robot requires privileged access to manage Docker containers

## 🚀 Quick Start

### 1. Clone the repository
```bash
git clone ...alloy-demo.git
cd alloy-demo
```

### 2. Start the stack
```bash
./run_demo.sh
```

This script automatically:
- Stops and cleans up previous containers
- Starts all services with docker-compose
- Generates test logs for the POS system

## 🔌 Services and Ports

| Service | Port | Description |
|---------|------|-------------|
| **Grafana** | [3000](http://localhost:3000) | Visualization dashboard |
| **Loki** | 3100 | Log storage |
| **Mimir** | 9009, 9095 | Metrics storage |
| **RabbitMQ** | 5672, [15672](http://localhost:15672) | Message queue (UI: 15672) |
| **FastAPI** | [8000](http://localhost:8000) | REST API |
| **iw-Robot** | 4050, 8050, [5901](http://localhost:5901) | Automation robot |
| **Connections Exporter** | 9701, 12745 | Connections exporter |

## 🎯 Main Components

### 1. Observability Stack
- **Grafana**: Metrics and logs visualization
- **Loki**: Log aggregation and storage
- **Mimir**: Prometheus-compatible metrics storage
- **Alloy Central**: Telemetry collection agent

### 2. Demo Infrastructure
- **RabbitMQ**: Message broker system
- **FastAPI**: Connections API
- **iw-Robot**: Process automation

### 3. Exporters
- **Connections Exporter**: Exports network connection metrics

## 📊 UI Access

### Grafana
- URL: http://localhost:3000
- Default user: `admin`
- Default password: `admin`

### RabbitMQ Management
- URL: http://localhost:15672
- Default user: `guest`
- Default password: `guest`

### FastAPI Docs
- URL: http://localhost:8000/docs

## 🛠️ Useful Commands

### View service logs
```bash
docker logs -f <service_name>
# Example:
docker logs -f grafana
```

### View all containers
```bash
docker ps
```

### Stop the stack
```bash
docker-compose down
```

### Restart a specific service
```bash
docker-compose restart <service_name>
```

## 📝 Notes

- POS logs are automatically generated in `/tmp/pos-logs/`
- Use `scripts/create_nodes.sh` to create dynamic nodes (POS, Servers, etc.)
- The script automatically cleans up previous containers before starting

## 🔍 Status Verification

After running `./run_demo.sh`, verify that all services are running:

```bash
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

All containers should show "Up" status.

## 🐛 Troubleshooting

### If a container doesn't start:
```bash
docker logs <container_name>
```

### If there are port conflicts:
Check that ports are not being used by other services:
```bash
lsof -i :<port>
```

### Clean everything and start from scratch:

**Option 1: Using the cleanup script (recommended)**
```bash
./scripts/destroy_demo.sh
./run_demo.sh
```

**Option 2: Manual cleanup**
```bash
# Remove all dynamic nodes first
docker ps -a --filter "ancestor=alloy-demo-node:pos" \
           --filter "ancestor=alloy-demo-node:server" \
           --filter "ancestor=alloy-demo-node:switch" \
           --filter "ancestor=alloy-demo-node:router" -q | xargs -r docker rm -f

# Then stop and remove base services with volumes
docker-compose down -v

# Start fresh
./run_demo.sh
```

The `destroy_demo.sh` script performs a complete cleanup:
- Removes all dynamic nodes (POS, Server, Switch, Router)
- Stops and removes all docker-compose services
- Removes all volumes
- Cleans up temporary log files
- Stops background processes (log generators)
- Removes Docker network

### iw-Robot container fails to start:
```bash
# Check if iw-robot folder exists
ls -la ./iwRobot/iw-robot/

# If missing, you need to manually place iw-Robot 1.2.0
# See the "iw-Robot Setup (REQUIRED)" section above
```

### iw-Robot cannot manage Docker containers:
```bash
# Verify Docker socket is accessible
docker exec iw-robot ls -la /var/run/docker.sock

# Should show: srw-rw---- 1 root docker 0 ... /var/run/docker.sock
```

## 🏗️ Creating Dynamic Nodes

After starting the base stack, you can create dynamic nodes (POS and Servers) to simulate a distributed infrastructure.

> ⚠️ **Important**: You must run `./run_demo.sh` first to create the Docker network and build the required images before creating dynamic nodes.

### Run the node creation script

```bash
./scripts/create_nodes.sh
```

The script will ask for:
- **Number of POS nodes** (Point of Sale systems)
- **Number of Server nodes**

#### Example: Create 3 POS and 2 Servers

```bash
./scripts/create_nodes.sh
# Enter: 3
# Enter: 2
```

Or run automatically:
```bash
echo -e "3\n2" | ./scripts/create_nodes.sh
```

### ✨ Created Node Features

Each node is created with:

- **📍 Random geographic location**: Within a 100km radius from CDMX center
- **🏷️ Random brand**: 
  - POS: `retail` or `acme`
  - Server: `AIX` or `acme`
- **🆔 Incremental ID**: Nodes are automatically numbered (pos1, pos2, server1, etc.)
- **🔌 Dynamic ports**: Automatically assigned to avoid conflicts
- **🌐 Shared network**: Connected to `alloy-demo_alloy_net`

### 📊 Verify Created Nodes

```bash
# View all POS and Server nodes
docker ps --filter "name=pos" --filter "name=server" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

### 🔎 Inspect Node Configuration

```bash
# View environment variables of a specific node
docker exec pos1 env | grep -E "NODE_TYPE|REGION|LOCATION|BRAND|LATITUDE|LONGITUDE"
```

**Example POS node configuration:**
```
NODE_TYPE=pos
REGION=region1
LOCATION=store-1
BRAND=acme
LATITUDE=19.263260
LONGITUDE=-100.126721
PROBLEM_MODE=healthy
```

### 📦 Ports Exposed by Nodes

#### POS Nodes
| Node | Metrics Port | Exporter Port |
|------|-------------|---------------|
| pos1 | 9301 | 12301 |
| pos2 | 9302 | 12302 |
| pos3 | 9303 | 12303 |

#### Server Nodes
| Node | Main Port | Additional Port | Exporter Port |
|------|-----------|-----------------|---------------|
| server1 | 9601 | 9611 | 12601 |
| server2 | 9602 | 9612 | 12602 |

### 🗑️ Remove Dynamic Nodes

```bash
# Stop and remove all POS nodes
docker ps -a --filter "name=pos" -q | xargs docker rm -f

# Stop and remove all Server nodes
docker ps -a --filter "name=server" -q | xargs docker rm -f

# OR remove all dynamic nodes at once (POS, Server, Switch, Router)
docker ps -a --filter "ancestor=alloy-demo-node:pos" \
           --filter "ancestor=alloy-demo-node:server" \
           --filter "ancestor=alloy-demo-node:switch" \
           --filter "ancestor=alloy-demo-node:router" -q | xargs -r docker rm -f
```

## 🤖 iw-Robot Workflow Details

### Automation Flow (`Observabilidad.edn`)

The imported workflow performs the following automation cycle:

1. **Monitor** - Checks RabbitMQ queue `alertas` for messages every 1 second
2. **Detect** - If alert message found, triggers remediation
3. **Remediate** - Executes `stopRam.sh` to stop the affected container
4. **Notify** - Sends email alert via Gmail with incident details
5. **Wait** - Sleeps for 10 seconds before next cycle

### RabbitMQ Integration

iw-Robot connects to RabbitMQ at:
- **Host**: `rabbitmq` (Docker network hostname)
- **Port**: 5672
- **VHost**: `/`
- **Queue**: `alertas`
- **Credentials**: guest/guest

### Accessing iw-Robot

| Access Method | URL/Command | Description |
|---------------|-------------|-------------|
| VNC | `vnc://localhost:5901` | Remote desktop access |
| HTTP API | `http://localhost:8050` | iw-Robot HTTP interface |
| HTTPS API | `https://localhost:4050` | iw-Robot secure interface |

## 📚 Next Steps

1. ⚠️ **Setup iw-Robot** (see [iw-Robot Setup](#-iw-robot-setup-required))
2. ✅ Start the base stack with `./run_demo.sh`
3. 🤖 Import `Observabilidad.edn` workflow into iw-Robot
4. ✅ Create dynamic nodes with `./scripts/create_nodes.sh`
5. 🎨 Access Grafana at http://localhost:3000
6. 📊 Explore the pre-configured dashboards
7. 📈 Review metrics from created nodes
8. 📝 Query logs in Loki

