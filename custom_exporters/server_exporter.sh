#!/bin/bash

# Get port from command line argument or use default
PORT=${1:-9600}
REGION=${REGION:-region1}
LOCATION=${LOCATION:-datacenter1}
BRAND=${BRAND:-retail}
PROBLEM_MODE=${PROBLEM_MODE:-healthy}

# Determine server type based on port
if [ "$PORT" = "9601" ]; then
    LOCATION=${LOCATION:-datacenter2}
fi

echo "Starting Server Exporter for $LOCATION ($REGION) on port $PORT, mode: $PROBLEM_MODE"

# Function to generate metrics
generate_metrics() {
  if [ "$PROBLEM_MODE" = "problem" ]; then
    # Problem mode: high CPU, low memory, high latency
    CPU_USAGE=$((90 + RANDOM%10))
    MEMORY_AVAILABLE=$((RANDOM%1000 + 100))
    DISK_FREE=$((RANDOM%20 + 5))
    LATENCY_MS=$((RANDOM%500 + 500))
  else
    # Healthy mode
    CPU_USAGE=$((RANDOM%30 + 5))
    MEMORY_AVAILABLE=$((RANDOM%2000 + 1000))
    DISK_FREE=$((RANDOM%50 + 50))
    LATENCY_MS=$((RANDOM%50 + 10))
  fi

  # Output metrics in Prometheus format
  cat <<EOF
# HELP server_cpu_usage CPU usage percentage
# TYPE server_cpu_usage gauge
server_cpu_usage{region="$REGION",location="$LOCATION",brand="$BRAND",type="server"} $CPU_USAGE
# HELP server_memory_available Available memory in MB
# TYPE server_memory_available gauge
server_memory_available{region="$REGION",location="$LOCATION",brand="$BRAND",type="server"} $MEMORY_AVAILABLE
# HELP server_disk_free_ratio Free disk space percentage
# TYPE server_disk_free_ratio gauge
server_disk_free_ratio{region="$REGION",location="$LOCATION",brand="$BRAND",type="server"} $DISK_FREE
# HELP server_request_latency_seconds Request latency in milliseconds
# TYPE server_request_latency_seconds gauge
server_request_latency_seconds{region="$REGION",location="$LOCATION",brand="$BRAND",type="server"} $LATENCY_MS
# HELP server_up Whether the server is up
# TYPE server_up gauge
server_up{region="$REGION",location="$LOCATION",brand="$BRAND",type="server"} 1
EOF
}

# Simple HTTP server that serves metrics
while true; do
  # Generate metrics once
  METRICS=$(generate_metrics)
  
  # Use netcat to serve HTTP responses
  {
    echo -e "HTTP/1.1 200 OK\r"
    echo -e "Content-Type: text/plain; version=0.0.4\r"
    echo -e "Content-Length: ${#METRICS}\r"
    echo -e "\r"
    echo -n "$METRICS"
  } | nc -l -p $PORT -q 1
  
  # Small delay to prevent high CPU usage
  sleep 1
done
