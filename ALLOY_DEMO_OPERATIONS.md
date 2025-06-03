# Alloy Retail Observability Demo - Guía de Operaciones

## 1. Visión General

### Arquitectura

```
+------------------+     +------------------+     +------------------+
|                  |     |                  |     |                  |
|    Nodos POS     |<--->|   Stack Central  |<--->|    Grafana       |
|   (Alloy)        |     |   (Loki, Mimir)  |     |   (Dashboards)   |
|                  |     |                  |     |                  |
+------------------+     +------------------+     +------------------+
         ^
         |
+--------+-------------+
|                      |
|  Red y Servidores    |
|  (Routers, Switches) |
|                      |
+----------------------+
```

### Componentes Principales

- **Stack Central**
  - **Loki**: Agregación centralizada de logs (puerto 3100)
  - **Mimir**: Almacenamiento de métricas (puertos 9009, 9095)
  - **Grafana**: Visualización (puerto 3000, usuario/contraseña: admin/admin)

- **Tipos de Nodos**
  | Tipo   | Puerto | Puerto UI | Descripción                  |
  |--------|--------|-----------|------------------------------|
  | Router | 9400   | 12348     | Dispositivos de red          |
  | Switch | 9401   | 12350     | Infraestructura de red       |
  | POS    | 9300   | 12349     | Terminales punto de venta    |
  | Server | 9100   | 12351     | Servidores de aplicaciones   |

## 2. Inicio Rápido

### 1. Construir Imágenes

```bash
# Hacer ejecutables los scripts
chmod +x build_node_images.sh generate_test_logs.sh

# Construir imágenes
./build_node_images.sh

# Generar logs de prueba
./generate_test_logs.sh
```

### 2. Iniciar Stack Central

```bash
# Iniciar servicios centrales
docker compose up -d loki mimir grafana
```

### 3. Iniciar Nodos

#### Nodo POS (Punto de Venta)
```bash
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
```

#### Nodo Router
```bash
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
```

## 3. Gestión de Nodos

### Variables de Entorno Comunes

| Variable       | Requerido | Ejemplo         | Descripción                              |
|----------------|-----------|-----------------|------------------------------------------|
| NODE_TYPE      | Sí       | pos, router     | Tipo de nodo                             |
| REGION         | Sí       | region1         | Región geográfica                        |
| LOCATION       | Sí       | store-1         | Ubicación física                         |
| BRAND          | Sí       | acme            | Marca/Organización                      |
| PROBLEM_MODE   | No       | healthy/problem | Simular problemas                       |
| DEVICE         | Red*     | core-router-01  | Identificador del dispositivo de red     |
| DEVICE_TYPE    | Red*     | cisco-nexus     | Tipo de dispositivo de red              |

*Requerido solo para nodos de red (router, switch)

### Comandos Útiles

```bash
# Ver nodos en ejecución
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Ver logs de un nodo
docker logs <nombre-nodo>

# Detener un nodo
docker stop <nombre-nodo>

# Eliminar un nodo
docker rm <nombre-nodo>
```

## 4. Monitoreo

### Acceso a Grafana
- URL: http://localhost:3000
- Usuario: admin
- Contraseña: admin

### Consultas Útiles

#### Métricas Básicas
```promql
# Estado de los nodos
up{job=~"node|pos|router|switch"}

# Uso de CPU
100 - (avg by(instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)

# Memoria disponible
node_memory_MemAvailable_bytes / 1024 / 1024
```

#### Logs
```logql
# Ver logs de error
{node_type=~"pos|router|switch"} |~ "error|fail|exception"

# Filtrar por ubicación
{location="store-1"}
```

## 5. Solución de Problemas

### Métricas no aparecen
1. Verificar que el nodo esté en ejecución
2. Comprobar conexión al stack central:
   ```bash
   # Desde el contenedor del nodo
   curl http://loki:3100/ready
   curl http://mimir:9009/ready
   ```
3. Revisar logs de Alloy:
   ```bash
   docker logs <nombre-nodo> 2>&1 | grep -i error
   ```

### Logs faltantes
1. Verificar que el directorio de logs esté montado:
   ```bash
   docker exec <nombre-nodo> ls -la /var/log/hostlogs/
   ```
2. Comprobar permisos de lectura
3. Verificar configuración de Loki en el nodo

## 6. Referencia Rápida

### Puertos
| Servicio | Puerto |
|----------|--------|
| Grafana  | 3000   |
| Loki     | 3100   |
| Mimir    | 9009   |
| Mimir UI | 9095   |

### Estructura de Directorios
```
.
├── configs/           # Configuraciones de Alloy
├── custom_exporters/  # Exportadores personalizados
├── grafana/
│   └── provisioning/  # Dashboards y fuentes de datos
├── docker-compose.yaml
└── build_node_images.sh
```

## 7. Próximos Pasos

1. Personalizar dashboards en Grafana
2. Configurar alertas
3. Añadir más nodos según sea necesario
4. Implementar autenticación segura

---
*Última actualización: 2025-06-04*
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

### 2. Iniciar Nodos de Ejemplo
```sh
docker compose up -d alloy_region1_server alloy_region1_pos alloy_region1_router
```

O cualquier subconjunto que desees. Los nodos disponibles son:
- `alloy_region1_server`: Servidor de aplicaciones
- `alloy_region1_pos`: Terminal punto de venta
- `alloy_region1_router`: Router de red
- `alloy_region1_switch`: Switch de red

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

### 4. Detener y Eliminar Nodos

Para detener un nodo:
```sh
docker compose stop <nombre-del-nodo>
```

Para eliminar un nodo:
```sh
docker compose rm -f <nombre-del-nodo>
```

Ejemplo para el nodo POS:
```sh
docker compose stop pos1
docker compose rm -f pos1
```

---

## Solución de Problemas

### Problemas Comunes

- **Alloy no inicia:**
  ```sh
  # Verificar logs de error
  docker exec <nombre_contenedor> tail -50 /tmp/alloy_stderr.log
  ```
  - Causas comunes: variables de entorno faltantes, errores de configuración, problemas de red con Loki/Mimir

- **Exportador no se ejecuta:**
  - Verificar que las variables de entorno sean correctas (`NODE_TYPE`, `DEVICE_TYPE`, etc.)
  - Revisar logs del contenedor: `docker logs <nombre_contenedor>`

- **Métricas/Logs no aparecen en Grafana:**
  - Verificar que el nodo esté en ejecución
  - Confirmar que el nodo se esté reportando a los endpoints correctos
  - Revisar la red del contenedor: `docker network inspect alloy-demo_alloy_net`

### Comandos Útiles

```sh
# Ver contenedores en ejecución
docker ps

# Ver logs de un contenedor
docker logs <nombre_contenedor>

# Ver métricas de Alloy
docker exec <nombre_contenedor> wget -qO- http://localhost:12345/metrics

# Inspeccionar red
docker network inspect alloy-demo_alloy_net

# Ver variables de entorno de un contenedor
docker inspect <nombre_contenedor> --format '{{.Config.Env}}' | tr ' ' '\n'
```

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

## Mejores Prácticas

### Construcción de Imágenes
```sh
# Reconstruir imágenes después de cambios
./build_node_images.sh
```

### Gestión de Nodos
- Usar nombres descriptivos para los contenedores
- Mapear puertos únicos para cada nodo
- Usar variables de entorno consistentes
- Para simular problemas, usar `PROBLEM_MODE=problem`
- Para nodos sanos, usar `PROBLEM_MODE=healthy`

### Monitoreo
- Verificar métricas en Grafana: http://localhost:3000
- Usuario: admin
- Contraseña: admin

## Lecturas Adicionales
- `METRICS_REFERENCE.md`: Detalles de métricas y consultas PromQL
- `README.md`: Información general del proyecto

---

*Documento actualizado: 2025-06-04*
*Mantener este documento actualizado con los comandos y configuraciones correctas*
