# Metrics Reference

> **Note:** This document is the single source of truth for all exporter metrics, labels, usage examples, and queries in the Alloy Retail Observability Demo. It replaces any separate summary files.

This document provides a comprehensive reference of all metrics exposed by the exporters in the observability stack.

## Table of Contents
- [Retail POS Exporter](#retail-pos-exporter)
- [Network Device Exporter](#network-device-exporter)
  - [Router Metrics](#router-metrics)
  - [Switch Metrics](#switch-metrics)
- [Node Exporter](#node-exporter)
- [Custom Exporter](#custom-exporter)
- [Example Queries](#example-queries)

## Retail POS Exporter

**Ports:** 9300 (store-1), 9301 (store-2)

This section documents the metrics exported by the simulated POS (Point-of-Sale) exporter used in the retail observability demo.

### Core Metrics

| Metric Name                         | Type   | Description                                  | Labels                                  |
|------------------------------------|--------|----------------------------------------------|------------------------------------------|
| pos_transactions_total             | Counter| Total number of transactions                 | location, brand, region                  |
| pos_amount_total                   | Counter| Total sales amount in USD                    | location, brand, region                  |
| pos_inventory_items                | Gauge  | Total items in inventory                     | location, brand, region                  |
| pos_cpu_usage                      | Gauge  | CPU usage percentage                         | location, brand, region                  |
| pos_memory_usage_bytes             | Gauge  | Memory usage in bytes                        | location, brand, region                  |
| pos_network_latency_seconds        | Gauge  | Network latency to central server            | location, brand, region                  |
| pos_failed_logins_total            | Counter| Failed login attempts                        | location, brand, region                  |
| pos_transaction_errors_total       | Counter| Errors during transactions                   | location, brand, region, error_type      |
| pos_payment_method_total           | Counter| Total transactions by payment method         | location, brand, region, method          |
| pos_active_sessions                | Gauge  | Active user sessions                         | location, brand, region                  |
| pos_printer_status                 | Gauge  | Status of printer device (1=OK, 0=Error)     | location, brand, region                  |
| pos_scanner_status                 | Gauge  | Status of barcode scanner (1=OK, 0=Error)    | location, brand, region                  |

### Hardware & Network Metrics

| Metric Name                         | Type   | Description                                  | Labels                                  |
|------------------------------------|--------|----------------------------------------------|------------------------------------------|
| pos_disk_usage_percent             | Gauge  | Disk usage percentage                        | location, brand, region                  |
| pos_cpu_temperature_celsius        | Gauge  | CPU temperature in Celsius                   | location, brand, region                  |
| pos_uptime_seconds                 | Counter| POS uptime in seconds                        | location, brand, region                  |
| pos_io_read_bytes_total            | Counter| Total read bytes from disk                   | location, brand, region                  |
| pos_io_write_bytes_total           | Counter| Total write bytes to disk                    | location, brand, region                  |
| pos_process_count                  | Gauge  | Number of running processes                  | location, brand, region                  |
| pos_firmware_version_info          | Gauge  | Firmware version info (static with version)  | location, brand, region, version         |
| pos_ping_latency_seconds           | Gauge  | Ping latency to HQ backend                   | location, brand, region, target          |
| pos_packet_loss_percent            | Gauge  | Simulated packet loss percentage             | location, brand, region                  |
| pos_dns_resolution_time_seconds    | Gauge  | DNS resolution time                          | location, brand, region                  |
| pos_interface_up                   | Gauge  | Whether network interface is up (1/0)        | location, brand, region, interface       |
| pos_problem_state                  | Gauge  | POS health status (0=OK, 1=Problem)          | location, brand, region                  |
| pos_error_code_last                | Gauge  | Last simulated error code                    | location, brand, region                  |

## Network Device Exporter

### Router Metrics
**Port:** 9400

| Metric Name | Type | Description | Labels |
|-------------|------|-------------|---------|
| `network_device_up` | Gauge | Device status (1=up, 0=down) | `device`, `location`, `type` |
| `network_device_cpu_usage` | Gauge | CPU usage percentage | `device`, `location`, `type` |
| `network_device_memory_usage` | Gauge | Memory usage percentage | `device`, `location`, `type` |
| `network_device_bandwidth_inbound` | Counter | Inbound bandwidth (bytes) | `device`, `location`, `type`, `interface` |
| `network_device_bandwidth_outbound` | Counter | Outbound bandwidth (bytes) | `device`, `location`, `type`, `interface` |
| `network_device_packet_loss` | Gauge | Packet loss percentage | `device`, `location`, `type` |
| `network_device_temperature_celsius` | Gauge | Device temperature | `device`, `location`, `type`, `sensor` |
| `network_device_interface_status` | Gauge | Interface status (1=up, 0=down) | `device`, `location`, `type`, `interface` |
| `network_device_uptime_seconds` | Counter | Device uptime in seconds | `device`, `location`, `type` |
| `network_device_connected_clients` | Gauge | Connected wireless clients | `device`, `location`, `type`, `ssid` |
| `network_device_dhcp_leases` | Gauge | Active DHCP leases | `device`, `location`, `type`, `pool` |
| `network_device_ports_total` | Gauge | Total number of ports | `device`, `location`, `type` |
| `network_device_ports_up` | Gauge | Active ports count | `device`, `location`, `type` |

### Switch Metrics
**Port:** 9401

Same metrics as router, with these label values:
- `device="switch-1"`
- `location="store-1"`
- `type="switch"`

## Node Exporter
**Port:** 9100

Standard Prometheus Node Exporter metrics including:

### CPU Metrics
- `node_cpu_seconds_total`
- `node_cpu_frequency_hertz`

### Memory Metrics
- `node_memory_MemTotal_bytes`
- `node_memory_MemFree_bytes`
- `node_memory_MemAvailable_bytes`
- `node_memory_Buffers_bytes`
- `node_memory_Cached_bytes`

### Disk Metrics
- `node_disk_reads_completed_total`
- `node_disk_writes_completed_total`
- `node_disk_read_bytes_total`
- `node_disk_written_bytes_total`

### Network Metrics
- `node_network_receive_bytes_total`
- `node_network_transmit_bytes_total`
- `node_network_receive_packets_total`
- `node_network_transmit_packets_total`

### System Metrics
- `node_boot_time_seconds`
- `node_time_seconds`
- `node_uname_info`

## Custom Exporter
**Port:** 9200

| Metric Name | Type | Description |
|-------------|------|-------------|
| `custom_temperature` | Gauge | Random temperature value (40-90°C) |

## Example Queries

curl -s "http://localhost:9009/prometheus/api/v1/label/__name__/values" | jq

### Retail Metrics
```promql
# Total transactions per store
sum by(location) (pos_transactions_total{status="success"})

# Inventory levels by product
sum by(location, product) (pos_inventory_items)

# CPU usage across all POS systems
sum by(location) (pos_cpu_usage)
```

### Network Device Metrics
```promql
# CPU usage across all network devices
network_device_cpu_usage

# Total active ports across all devices
sum(network_device_ports_up)

# Bandwidth usage per interface
rate(network_device_bandwidth_outbound[5m]) * 8  # Convert to bits/second
```

### System Metrics
```promql
# Available memory percentage
(node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes) * 100

# CPU usage percentage
100 - (avg by(instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)

# Disk usage percentage
(1 - (node_filesystem_avail_bytes{mountpoint="/"} / node_filesystem_size_bytes{mountpoint="/"})) * 100
```

### Alerting Rules
```yaml
# Example alert for high CPU usage
alert: HighCPUUsage
expr: |
  100 - (avg by(instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 80
for: 5m
labels:
  severity: warning
annotations:
  summary: "High CPU usage on {{ $labels.instance }}"
  description: "CPU usage is {{ $value }}%"
```

This documentation provides a complete reference for all metrics available in the observability stack. Use these metrics to create dashboards and alerts that monitor your retail and network infrastructure.
