#!/bin/bash

# Get port from command line argument or use default
PORT=${1:-9300}

# Determine store location based on port
if [ "$PORT" = "9301" ]; then
    LOCATION="store-2"
else
    LOCATION="store-1"
fi

echo "Starting Retail POS Exporter for $LOCATION on port $PORT"

while true; do
  # Generate metrics with the appropriate location
  RESPONSE=$(cat <<EOF
# HELP pos_transactions_total Total number of transactions
# TYPE pos_transactions_total counter
pos_transactions_total{brand="brand1",location="$LOCATION",status="success"} $((RANDOM%1000))
pos_transactions_total{brand="brand1",location="$LOCATION",status="failed"} $((RANDOM%10))
# HELP pos_amount_total Total transaction amount
# TYPE pos_amount_total counter
pos_amount_total{brand="brand1",location="$LOCATION",currency="USD"} $((RANDOM%10000))
# HELP pos_inventory_items Number of items in inventory
# TYPE pos_inventory_items gauge
pos_inventory_items{brand="brand1",location="$LOCATION",product="laptops"} $((RANDOM%100))
pos_inventory_items{brand="brand1",location="$LOCATION",product="phones"} $((RANDOM%200))
# HELP pos_system_uptime_seconds System uptime in seconds
# TYPE pos_system_uptime_seconds counter
pos_system_uptime_seconds{brand="brand1",location="$LOCATION"} $(( ( $(date +%s) - 1609459200 ) + (RANDOM%86400) ))
# HELP pos_cpu_usage CPU usage percentage
# TYPE pos_cpu_usage gauge
pos_cpu_usage{brand="brand1",location="$LOCATION",cpu="0"} $((RANDOM%100))
# HELP pos_memory_usage_bytes Memory usage in bytes
# TYPE pos_memory_usage_bytes gauge
pos_memory_usage_bytes{brand="brand1",location="$LOCATION"} $(( (RANDOM%8000000) + 2000000 ))
EOF
)
  # Use -N flag to close connection after sending response
  echo -e "HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\n\r\n$RESPONSE" | nc -l -N -p "$PORT"
  # Small delay to prevent high CPU usage
  sleep 0.1
done