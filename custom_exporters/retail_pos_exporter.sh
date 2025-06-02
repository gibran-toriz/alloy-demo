#!/bin/bash

# Get port from command line argument or use default
PORT=${1:-9300}
REGION=${REGION:-region1}
LOCATION=${LOCATION:-store-1}
BRAND=${BRAND:-brand1}
CURRENCY=${CURRENCY:-USD}
PROBLEM_MODE=${PROBLEM_MODE:-healthy}

# Determine store location based on port
if [ "$PORT" = "9301" ]; then
    LOCATION=${LOCATION:-store-2}
fi

echo "Starting Retail POS Exporter for $LOCATION ($REGION) on port $PORT, mode: $PROBLEM_MODE"

while true; do
  if [ "$PROBLEM_MODE" = "problem" ]; then
    # Erratic metrics: high CPU, low inventory, more failed transactions
    TX_SUCCESS=$((RANDOM%100 + 10))
    TX_FAILED=$((RANDOM%50 + 20))
    AMOUNT_TOTAL=$((RANDOM%1000 + 100))
    INV_LAPTOPS=$((RANDOM%5))
    INV_PHONES=$((RANDOM%10))
    CPU_USAGE=$((80 + RANDOM%20))
    MEM_USAGE=$(( (RANDOM%2000000) + 1000000 ))
  else
    # Healthy metrics
    TX_SUCCESS=$((RANDOM%1000 + 500))
    TX_FAILED=$((RANDOM%5))
    AMOUNT_TOTAL=$((RANDOM%10000 + 5000))
    INV_LAPTOPS=$((RANDOM%100 + 50))
    INV_PHONES=$((RANDOM%200 + 100))
    CPU_USAGE=$((RANDOM%50))
    MEM_USAGE=$(( (RANDOM%8000000) + 2000000 ))
  fi
  RESPONSE=$(cat <<EOF
# HELP pos_transactions_total Total number of transactions
# TYPE pos_transactions_total counter
pos_transactions_total{brand="$BRAND",region="$REGION",location="$LOCATION",status="success"} $TX_SUCCESS
pos_transactions_total{brand="$BRAND",region="$REGION",location="$LOCATION",status="failed"} $TX_FAILED
# HELP pos_amount_total Total transaction amount
# TYPE pos_amount_total counter
pos_amount_total{brand="$BRAND",region="$REGION",location="$LOCATION",currency="$CURRENCY"} $AMOUNT_TOTAL
# HELP pos_inventory_items Number of items in inventory
# TYPE pos_inventory_items gauge
pos_inventory_items{brand="$BRAND",region="$REGION",location="$LOCATION",product="laptops"} $INV_LAPTOPS
pos_inventory_items{brand="$BRAND",region="$REGION",location="$LOCATION",product="phones"} $INV_PHONES
# HELP pos_system_uptime_seconds System uptime in seconds
# TYPE pos_system_uptime_seconds counter
pos_system_uptime_seconds{brand="$BRAND",region="$REGION",location="$LOCATION"} $(( ( $(date +%s) - 1609459200 ) + (RANDOM%86400) ))
# HELP pos_cpu_usage CPU usage percentage
# TYPE pos_cpu_usage gauge
pos_cpu_usage{brand="$BRAND",region="$REGION",location="$LOCATION",cpu="0"} $CPU_USAGE
# HELP pos_memory_usage_bytes Memory usage in bytes
# TYPE pos_memory_usage_bytes gauge
pos_memory_usage_bytes{brand="$BRAND",region="$REGION",location="$LOCATION"} $MEM_USAGE
EOF
)
  # Use -N flag to close connection after sending response
  echo -e "HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\n\r\n$RESPONSE" | nc -l -N -p "$PORT"
  # Small delay to prevent high CPU usage
  sleep 0.1
done