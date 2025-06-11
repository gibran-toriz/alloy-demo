#!/bin/bash

PORT=9300
INTERVAL=1
LOCATION=${LOCATION:-"store-1"}
REGION=${REGION:-"us-east"}
BRAND=${BRAND:-"AcmePOS"}
HOSTNAME=$(hostname)

while true; do
  cat <<EOF > /tmp/metrics.txt
# HELP pos_transactions_total Total number of transactions
# TYPE pos_transactions_total counter
pos_transactions_total{location="$LOCATION", brand="$BRAND", region="$REGION"} $((RANDOM % 10000 + 1000))

# HELP pos_amount_total Total sales amount in USD
# TYPE pos_amount_total counter
pos_amount_total{location="$LOCATION", brand="$BRAND", region="$REGION"} $(shuf -i 10000-100000 -n 1)

# HELP pos_inventory_items Total items in inventory
# TYPE pos_inventory_items gauge
pos_inventory_items{location="$LOCATION", brand="$BRAND", region="$REGION"} $((RANDOM % 1000 + 100))

# HELP pos_cpu_usage CPU usage percentage
# TYPE pos_cpu_usage gauge
pos_cpu_usage{location="$LOCATION", brand="$BRAND", region="$REGION"} $(shuf -i 10-95 -n 1)

# HELP pos_memory_usage_bytes Memory usage in bytes
# TYPE pos_memory_usage_bytes gauge
pos_memory_usage_bytes{location="$LOCATION", brand="$BRAND", region="$REGION"} $((RANDOM % 2000000000 + 500000000))

# HELP pos_network_latency_seconds Network latency in seconds
# TYPE pos_network_latency_seconds gauge
pos_network_latency_seconds{location="$LOCATION", brand="$BRAND", region="$REGION"} 0.$((RANDOM % 200))

# HELP pos_failed_logins_total Failed login attempts
# TYPE pos_failed_logins_total counter
pos_failed_logins_total{location="$LOCATION", brand="$BRAND", region="$REGION"} $((RANDOM % 20))

# HELP pos_transaction_errors_total Errors during transactions
# TYPE pos_transaction_errors_total counter
pos_transaction_errors_total{location="$LOCATION", brand="$BRAND", region="$REGION", error_type="timeout"} $((RANDOM % 10))

# HELP pos_payment_method_total Total transactions by payment method
# TYPE pos_payment_method_total counter
pos_payment_method_total{location="$LOCATION", brand="$BRAND", region="$REGION", method="cash"} $((RANDOM % 100))
pos_payment_method_total{location="$LOCATION", brand="$BRAND", region="$REGION", method="card"} $((RANDOM % 100))
pos_payment_method_total{location="$LOCATION", brand="$BRAND", region="$REGION", method="mobile"} $((RANDOM % 50))

# HELP pos_active_sessions Active user sessions
# TYPE pos_active_sessions gauge
pos_active_sessions{location="$LOCATION", brand="$BRAND", region="$REGION"} $((RANDOM % 10))

# HELP pos_printer_status Status of printer device (1=OK, 0=Error)
# TYPE pos_printer_status gauge
pos_printer_status{location="$LOCATION", brand="$BRAND", region="$REGION"} $((RANDOM % 2))

# HELP pos_scanner_status Status of barcode scanner (1=OK, 0=Error)
# TYPE pos_scanner_status gauge
pos_scanner_status{location="$LOCATION", brand="$BRAND", region="$REGION"} $((RANDOM % 2))

# === New hardware/network metrics ===

# HELP pos_disk_usage_percent Disk usage percentage
# TYPE pos_disk_usage_percent gauge
pos_disk_usage_percent{location="$LOCATION", brand="$BRAND", region="$REGION"} $(shuf -i 50-95 -n 1)

# HELP pos_cpu_temperature_celsius CPU temperature
# TYPE pos_cpu_temperature_celsius gauge
pos_cpu_temperature_celsius{location="$LOCATION", brand="$BRAND", region="$REGION"} $((RANDOM % 20 + 50))

# HELP pos_uptime_seconds POS uptime in seconds
# TYPE pos_uptime_seconds counter
pos_uptime_seconds{location="$LOCATION", brand="$BRAND", region="$REGION"} $((RANDOM % 86400))

# HELP pos_io_read_bytes_total Total read bytes from disk
# TYPE pos_io_read_bytes_total counter
pos_io_read_bytes_total{location="$LOCATION", brand="$BRAND", region="$REGION"} $((RANDOM % 50000000))

# HELP pos_io_write_bytes_total Total write bytes to disk
# TYPE pos_io_write_bytes_total counter
pos_io_write_bytes_total{location="$LOCATION", brand="$BRAND", region="$REGION"} $((RANDOM % 70000000))

# HELP pos_process_count Number of running processes
# TYPE pos_process_count gauge
pos_process_count{location="$LOCATION", brand="$BRAND", region="$REGION"} $((RANDOM % 200 + 50))

# HELP pos_firmware_version_info Firmware version info (static label)
# TYPE pos_firmware_version_info gauge
pos_firmware_version_info{location="$LOCATION", brand="$BRAND", region="$REGION", version="v1.3.2"} 1

# HELP pos_ping_latency_seconds Ping latency to HQ backend
# TYPE pos_ping_latency_seconds gauge
pos_ping_latency_seconds{location="$LOCATION", brand="$BRAND", region="$REGION", target="hq.backend"} 0.$((RANDOM % 300))

# HELP pos_packet_loss_percent Simulated packet loss %
# TYPE pos_packet_loss_percent gauge
pos_packet_loss_percent{location="$LOCATION", brand="$BRAND", region="$REGION"} $((RANDOM % 5))

# HELP pos_dns_resolution_time_seconds DNS resolution time
# TYPE pos_dns_resolution_time_seconds gauge
pos_dns_resolution_time_seconds{location="$LOCATION", brand="$BRAND", region="$REGION"} 0.$((RANDOM % 300))

# HELP pos_interface_up Whether network interface is up (1) or down (0)
# TYPE pos_interface_up gauge
pos_interface_up{location="$LOCATION", brand="$BRAND", region="$REGION", interface="eth0"} 1

# HELP pos_problem_state POS health status (0=OK, 1=Problem)
# TYPE pos_problem_state gauge
pos_problem_state{location="$LOCATION", brand="$BRAND", region="$REGION"} $((RANDOM % 2))

# HELP pos_error_code_last Last error code (simulated)
# TYPE pos_error_code_last gauge
pos_error_code_last{location="$LOCATION", brand="$BRAND", region="$REGION"} $((RANDOM % 10))
EOF

  # Serve metrics
  { echo -ne "HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\n\r\n"; cat /tmp/metrics.txt; } | nc -l -p $PORT -q 1
  sleep $INTERVAL
done