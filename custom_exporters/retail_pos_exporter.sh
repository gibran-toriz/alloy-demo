#!/bin/bash

# Get port from command line argument or use default
PORT=${1:-9300}
REGION=${REGION:-region1}
LOCATION=${LOCATION:-store-1}
BRAND=${BRAND:-brand1}
CURRENCY=${CURRENCY:-USD}
PROBLEM_MODE=${PROBLEM_MODE:-healthy}
LATITUDE=${LATITUDE:-0.0}
LONGITUDE=${LONGITUDE:-0.0}

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

    # New metrics for problem mode
    TX_ERROR_TYPE="timeout"
    TX_ERRORS=$((RANDOM%20 + 5))
    PAYMENT_METHODS=("cash" "credit_card" "mobile")
    PM_CASH=$((RANDOM%20 + 5))
    PM_CC=$((RANDOM%10 + 2))
    PM_MOBILE=$((RANDOM%5 + 1))
    PRINTER_STATUS=0
    SCANNER_STATUS=0
    FAILED_LOGINS=$((RANDOM%10 + 5))
    ACTIVE_SESSIONS=$((RANDOM%2))
    NETWORK_LATENCY=$(awk -v min=0.5 -v max=2.0 'BEGIN{srand(); print min+rand()*(max-min)}')
  else
    # Healthy metrics
    TX_SUCCESS=$((RANDOM%1000 + 500))
    TX_FAILED=$((RANDOM%5))
    AMOUNT_TOTAL=$((RANDOM%10000 + 5000))
    INV_LAPTOPS=$((RANDOM%100 + 50))
    INV_PHONES=$((RANDOM%200 + 100))
    CPU_USAGE=$((RANDOM%50))
    MEM_USAGE=$(( (RANDOM%8000000) + 2000000 ))

    # New metrics for healthy mode
    TX_ERROR_TYPE="none"
    TX_ERRORS=0
    PAYMENT_METHODS=("cash" "credit_card" "mobile")
    PM_CASH=$((RANDOM%100 + 50))
    PM_CC=$((RANDOM%80 + 40))
    PM_MOBILE=$((RANDOM%30 + 10))
    PRINTER_STATUS=1
    SCANNER_STATUS=1
    FAILED_LOGINS=$((RANDOM%2))
    ACTIVE_SESSIONS=$((RANDOM%5 + 1))
    NETWORK_LATENCY=$(awk -v min=0.05 -v max=0.2 'BEGIN{srand(); print min+rand()*(max-min)}')
  fi
  RESPONSE=$(cat <<EOF
# HELP pos_transactions_total Total number of transactions
# TYPE pos_transactions_total counter
pos_transactions_total{brand="$BRAND",region="$REGION",location="$LOCATION",status="success",latitude="$LATITUDE",longitude="$LONGITUDE"} $TX_SUCCESS
pos_transactions_total{brand="$BRAND",region="$REGION",location="$LOCATION",status="failed",latitude="$LATITUDE",longitude="$LONGITUDE"} $TX_FAILED
# HELP pos_amount_total Total transaction amount
# TYPE pos_amount_total counter
pos_amount_total{brand="$BRAND",region="$REGION",location="$LOCATION",currency="$CURRENCY",latitude="$LATITUDE",longitude="$LONGITUDE"} $AMOUNT_TOTAL
# HELP pos_inventory_items Number of items in inventory
# TYPE pos_inventory_items gauge
pos_inventory_items{brand="$BRAND",region="$REGION",location="$LOCATION",product="laptops",latitude="$LATITUDE",longitude="$LONGITUDE"} $INV_LAPTOPS
pos_inventory_items{brand="$BRAND",region="$REGION",location="$LOCATION",product="phones",latitude="$LATITUDE",longitude="$LONGITUDE"} $INV_PHONES
# HELP pos_system_uptime_seconds System uptime in seconds
# TYPE pos_system_uptime_seconds counter
pos_system_uptime_seconds{brand="$BRAND",region="$REGION",location="$LOCATION",latitude="$LATITUDE",longitude="$LONGITUDE"} $(( ( $(date +%s) - 1609459200 ) + (RANDOM%86400) ))
# HELP pos_cpu_usage CPU usage percentage
# TYPE pos_cpu_usage gauge
pos_cpu_usage{brand="$BRAND",region="$REGION",location="$LOCATION",cpu="0",latitude="$LATITUDE",longitude="$LONGITUDE"} $CPU_USAGE
# HELP pos_memory_usage_bytes Memory usage in bytes
# TYPE pos_memory_usage_bytes gauge
pos_memory_usage_bytes{brand="$BRAND",region="$REGION",location="$LOCATION",latitude="$LATITUDE",longitude="$LONGITUDE"} $MEM_USAGE
# HELP pos_transaction_errors_total Number of failed transactions
# TYPE pos_transaction_errors_total counter
pos_transaction_errors_total{error_type="$TX_ERROR_TYPE",brand="$BRAND",region="$REGION",location="$LOCATION",latitude="$LATITUDE",longitude="$LONGITUDE"} $TX_ERRORS
# HELP pos_payment_method_total Count by payment method
# TYPE pos_payment_method_total counter
pos_payment_method_total{method="cash",brand="$BRAND",region="$REGION",location="$LOCATION",latitude="$LATITUDE",longitude="$LONGITUDE"} $PM_CASH
pos_payment_method_total{method="credit_card",brand="$BRAND",region="$REGION",location="$LOCATION",latitude="$LATITUDE",longitude="$LONGITUDE"} $PM_CC
pos_payment_method_total{method="mobile",brand="$BRAND",region="$REGION",location="$LOCATION",latitude="$LATITUDE",longitude="$LONGITUDE"} $PM_MOBILE
# HELP pos_printer_status Printer health (1=ok, 0=error)
# TYPE pos_printer_status gauge
pos_printer_status{printer_id="printer-1",brand="$BRAND",region="$REGION",location="$LOCATION",latitude="$LATITUDE",longitude="$LONGITUDE"} $PRINTER_STATUS
# HELP pos_scanner_status Scanner health (1=ok, 0=error)
# TYPE pos_scanner_status gauge
pos_scanner_status{scanner_id="scanner-1",brand="$BRAND",region="$REGION",location="$LOCATION",latitude="$LATITUDE",longitude="$LONGITUDE"} $SCANNER_STATUS
# HELP pos_failed_logins_total Failed login attempts
# TYPE pos_failed_logins_total counter
pos_failed_logins_total{brand="$BRAND",region="$REGION",location="$LOCATION",user="cashier1",latitude="$LATITUDE",longitude="$LONGITUDE"} $FAILED_LOGINS
# HELP pos_active_sessions Number of logged-in users
# TYPE pos_active_sessions gauge
pos_active_sessions{brand="$BRAND",region="$REGION",location="$LOCATION",latitude="$LATITUDE",longitude="$LONGITUDE"} $ACTIVE_SESSIONS
# HELP pos_network_latency_seconds Network latency to central server
# TYPE pos_network_latency_seconds gauge
pos_network_latency_seconds{brand="$BRAND",region="$REGION",location="$LOCATION",latitude="$LATITUDE",longitude="$LONGITUDE"} $NETWORK_LATENCY
EOF
)
  # Use -N flag to close connection after sending response
  echo -e "HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\n\r\n$RESPONSE" | nc -l -N -p "$PORT"
  # Small delay to prevent high CPU usage
  sleep 0.1
done