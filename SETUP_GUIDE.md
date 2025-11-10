# Setup Guide - Alloy Demo POC

## 📋 Prerequisites

- Docker & Docker Compose
- Python 3.x
- Git

## 🚀 Quick Start

### 1. Clone the repository
```bash
git clone https://github.com/gibran-toriz/alloy-demo.git
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
- Use `create_nodes.sh` to create dynamic nodes (POS, Servers, etc.)
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
```bash
docker-compose down -v  # Also removes volumes
./run_demo.sh
```

## 🏗️ Creating Dynamic Nodes

After starting the base stack, you can create dynamic nodes (POS and Servers) to simulate a distributed infrastructure.

### Run the node creation script

```bash
./create_nodes.sh
```

The script will ask for:
- **Number of POS nodes** (Point of Sale systems)
- **Number of Server nodes**

#### Example: Create 3 POS and 2 Servers

```bash
./create_nodes.sh
# Enter: 3
# Enter: 2
```

Or run automatically:
```bash
echo -e "3\n2" | ./create_nodes.sh
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
```

## 📚 Next Steps

1. ✅ Start the base stack with `./run_demo.sh`
2. ✅ Create dynamic nodes with `./create_nodes.sh`
3. 🎨 Access Grafana at http://localhost:3000
4. 📊 Explore the pre-configured dashboards
5. 📈 Review metrics from created nodes
6. 📝 Query logs in Loki

## 🎯 Componentes Principales

### 1. Stack de Observabilidad
- **Grafana**: Visualización de métricas y logs
- **Loki**: Agregación y almacenamiento de logs
- **Mimir**: Almacenamiento de métricas tipo Prometheus
- **Alloy Central**: Agente de telemetría

### 2. Infraestructura de Demo
- **RabbitMQ**: Sistema de mensajería
- **FastAPI**: API de conexiones
- **iw-Robot**: Automatización de procesos

### 3. Exportadores
- **Connections Exporter**: Exporta métricas de conexiones de red

## 📊 Acceso a las UIs

### Grafana
- URL: http://localhost:3000
- Usuario por defecto: `admin`
- Password por defecto: `admin`

### RabbitMQ Management
- URL: http://localhost:15672
- Usuario por defecto: `guest`
- Password por defecto: `guest`

### FastAPI Docs
- URL: http://localhost:8000/docs

## 🛠️ Comandos Útiles

### Ver logs de un servicio
```bash
docker logs -f <nombre_servicio>
# Ejemplo:
docker logs -f grafana
```

### Ver todos los contenedores
```bash
docker ps
```

### Detener el stack
```bash
docker-compose down
```

### Reiniciar un servicio específico
```bash
docker-compose restart <nombre_servicio>
```

## 📝 Notas

- Los logs de POS se generan automáticamente en `/tmp/pos-logs/`
- Usa `create_nodes.sh` para crear nodos dinámicamente (POS, Servers, etc.)
- El script limpia automáticamente contenedores anteriores antes de iniciar

## 🔍 Verificación del Estado

Después de ejecutar `./run_demo.sh`, verifica que todos los servicios estén corriendo:

```bash
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

Todos los contenedores deberían mostrar estado "Up".

## 🐛 Troubleshooting

### Si un contenedor no inicia:
```bash
docker logs <nombre_contenedor>
```

### Si hay conflictos de puertos:
Verifica que los puertos no estén siendo usados por otros servicios:
```bash
lsof -i :<puerto>
```

### Limpiar todo y empezar de cero:
```bash
docker-compose down -v  # Elimina también los volúmenes
./run_demo.sh
```

## 🏗️ Crear Nodos Dinámicos

Después de levantar el stack base, puedes crear nodos dinámicos (POS y Servers) para simular una infraestructura distribuida.

### Ejecutar el script de creación de nodos

```bash
./create_nodes.sh
```

El script te pedirá:
- **Número de nodos POS** (Point of Sale - Puntos de Venta)
- **Número de nodos Server** (Servidores)

#### Ejemplo: Crear 3 POS y 2 Servers

```bash
./create_nodes.sh
# Ingresa: 3
# Ingresa: 2
```

O ejecuta automáticamente:
```bash
echo -e "3\n2" | ./create_nodes.sh
```

### ✨ Características de los Nodos Creados

Cada nodo se crea con:

- **📍 Ubicación geográfica aleatoria**: Dentro de un radio de 100km desde el centro de CDMX
- **🏷️ Brand aleatorio**: 
  - POS: `retail` o `acme`
  - Server: `AIX` o `acme`
- **🆔 ID incremental**: Los nodos se numeran automáticamente (pos1, pos2, server1, etc.)
- **🔌 Puertos dinámicos**: Se asignan automáticamente para evitar conflictos
- **🌐 Red compartida**: Conectados a `alloy-demo_alloy_net`

### 📊 Verificar Nodos Creados

```bash
# Ver todos los nodos POS y Server
docker ps --filter "name=pos" --filter "name=server" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

### � Inspeccionar Configuración de un Nodo

```bash
# Ver variables de entorno de un nodo específico
docker exec pos1 env | grep -E "NODE_TYPE|REGION|LOCATION|BRAND|LATITUDE|LONGITUDE"
```

**Ejemplo de configuración de un nodo POS:**
```
NODE_TYPE=pos
REGION=region1
LOCATION=store-1
BRAND=acme
LATITUDE=19.263260
LONGITUDE=-100.126721
PROBLEM_MODE=healthy
```

### 📦 Puertos Expuestos por los Nodos

#### Nodos POS
| Nodo | Puerto Métricas | Puerto Exporter |
|------|----------------|-----------------|
| pos1 | 9301 | 12301 |
| pos2 | 9302 | 12302 |
| pos3 | 9303 | 12303 |

#### Nodos Server
| Nodo | Puerto Principal | Puerto Adicional | Puerto Exporter |
|------|-----------------|------------------|-----------------|
| server1 | 9601 | 9611 | 12601 |
| server2 | 9602 | 9612 | 12602 |

### 🗑️ Eliminar Nodos Dinámicos

```bash
# Detener y eliminar todos los nodos POS
docker ps -a --filter "name=pos" -q | xargs docker rm -f

# Detener y eliminar todos los nodos Server
docker ps -a --filter "name=server" -q | xargs docker rm -f
```

## �📚 Próximos Pasos

1. ✅ Levantar el stack base con `./run_demo.sh`
2. ✅ Crear nodos dinámicos con `./create_nodes.sh`
3. 🎨 Acceder a Grafana en http://localhost:3000
4. 📊 Explorar los dashboards preconfigurrados
5. 📈 Revisar las métricas de los nodos creados
6. 📝 Consultar los logs en Loki
