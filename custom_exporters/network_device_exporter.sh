#!/bin/bash

# Get port from command line argument or use default
PORT=${1:-9400}
REGION=${REGION:-region1}
LOCATION=${LOCATION:-store-1}
DEVICE=${DEVICE:-router-1}
DEVICE_TYPE=${DEVICE_TYPE:-router}
PROBLEM_MODE=${PROBLEM_MODE:-healthy}

# Determine device type and location based on port
if [ "$PORT" = "9500" ] || [ "$NODE_TYPE" = "switch" ]; then
    DEVICE_TYPE=${DEVICE_TYPE:-switch}
    DEVICE=${DEVICE:-switch-1}
fi

echo "Starting Network Device Exporter for $DEVICE ($DEVICE_TYPE, $REGION/$LOCATION) on port $PORT, mode: $PROBLEM_MODE"

while true; do
  if [ "$PROBLEM_MODE" = "problem" ]; then
    # Erratic: device down, high CPU, high packet loss
    UP=0
    CPU=$((90 + RANDOM%10))
    MEM=$((90 + RANDOM%10))
    PKT_LOSS=$(awk -v n=$RANDOM 'BEGIN{printf "%.2f", 20 + (n/327.67)}')
    TEMP=$((70 + RANDOM%10))
    PORTS_UP=0
  else
    # Healthy
    UP=1
    CPU=$((RANDOM%50))
    MEM=$((RANDOM%60))
    PKT_LOSS=$(awk -v n=$RANDOM 'BEGIN{printf "%.2f", n/3276.7}')
    TEMP=$((40 + RANDOM%20))
    PORTS_UP=$((RANDOM%8 + 1))
  fi
  RESPONSE=$(cat <<EOF
# HELP network_device_up Whether the device is up (1) or down (0)
# TYPE network_device_up gauge
network_device_up{device="$DEVICE",region="$REGION",location="$LOCATION",type="$DEVICE_TYPE"} $UP
# HELP network_device_cpu_usage CPU usage percentage
# TYPE network_device_cpu_usage gauge
network_device_cpu_usage{device="$DEVICE",region="$REGION",location="$LOCATION",type="$DEVICE_TYPE"} $CPU
# HELP network_device_memory_usage Memory usage percentage
# TYPE network_device_memory_usage gauge
network_device_memory_usage{device="$DEVICE",region="$REGION",location="$LOCATION",type="$DEVICE_TYPE"} $MEM
# HELP network_device_bandwidth_inbound Inbound bandwidth usage in bytes
# TYPE network_device_bandwidth_inbound counter
network_device_bandwidth_inbound{device="$DEVICE",region="$REGION",location="$LOCATION",type="$DEVICE_TYPE",interface="wan1"} $((RANDOM%1000000000))
# HELP network_device_bandwidth_outbound Outbound bandwidth usage in bytes
# TYPE network_device_bandwidth_outbound counter
network_device_bandwidth_outbound{device="$DEVICE",region="$REGION",location="$LOCATION",type="$DEVICE_TYPE",interface="wan1"} $((RANDOM%500000000))
# HELP network_device_packet_loss Packet loss percentage
# TYPE network_device_packet_loss gauge
network_device_packet_loss{device="$DEVICE",region="$REGION",location="$LOCATION",type="$DEVICE_TYPE"} $PKT_LOSS
# HELP network_device_temperature_celsius Device temperature in Celsius
# TYPE network_device_temperature_celsius gauge
network_device_temperature_celsius{device="$DEVICE",region="$REGION",location="$LOCATION",type="$DEVICE_TYPE",sensor="cpu"} $TEMP
# HELP network_device_interface_status Interface status (1=up, 0=down)
# TYPE network_device_interface_status gauge
network_device_interface_status{device="$DEVICE",region="$REGION",location="$LOCATION",type="$DEVICE_TYPE",interface="eth0"} $UP
network_device_interface_status{device="$DEVICE",region="$REGION",location="$LOCATION",type="$DEVICE_TYPE",interface="eth1"} $UP
network_device_interface_status{device="$DEVICE",region="$REGION",location="$LOCATION",type="$DEVICE_TYPE",interface="wlan0"} $((RANDOM%2))
# HELP network_device_uptime_seconds Device uptime in seconds
# TYPE network_device_uptime_seconds counter
network_device_uptime_seconds{device="$DEVICE",region="$REGION",location="$LOCATION",type="$DEVICE_TYPE"} $(( ( $(date +%s) - 1609459200 ) + (RANDOM%2592000) ))
# HELP network_device_connected_clients Number of connected wireless clients
# TYPE network_device_connected_clients gauge
network_device_connected_clients{device="$DEVICE",region="$REGION",location="$LOCATION",type="$DEVICE_TYPE",ssid="Store-WiFi"} $((RANDOM%50))
# HELP network_device_dhcp_leases Number of active DHCP leases
# TYPE network_device_dhcp_leases gauge
network_device_dhcp_leases{device="$DEVICE",region="$REGION",location="$LOCATION",type="$DEVICE_TYPE",pool="main"} $((20 + RANDOM%30))
# HELP network_device_ports_total Total number of ports
# TYPE network_device_ports_total gauge
network_device_ports_total{device="$DEVICE",region="$REGION",location="$LOCATION",type="$DEVICE_TYPE"} $([ "$DEVICE_TYPE" = "router" ] && echo "8" || echo "24")
# HELP network_device_ports_up Number of active ports
# TYPE network_device_ports_up gauge
network_device_ports_up{device="$DEVICE",region="$REGION",location="$LOCATION",type="$DEVICE_TYPE"} $PORTS_UP
EOF
)
  # Use -N flag to close connection after sending response
  echo -e "HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\n\r\n$RESPONSE" | nc -l -N -p "$PORT"
  # Small delay to prevent high CPU usage
  sleep 0.1
done