#!/bin/bash

# Get port from command line argument or use default
PORT=${1:-9400}

# Determine device type and location based on port
if [ "$PORT" = "9400" ]; then
    DEVICE="router-1"
    LOCATION="store-1"
    DEVICE_TYPE="router"
else
    DEVICE="switch-1"
    LOCATION="store-1"
    DEVICE_TYPE="switch"
fi

echo "Starting Network Device Exporter for $DEVICE ($DEVICE_TYPE) on port $PORT"

while true; do
  # Generate metrics with the appropriate device and location
  RESPONSE=$(cat <<EOF
# HELP network_device_up Whether the device is up (1) or down (0)
# TYPE network_device_up gauge
network_device_up{device="$DEVICE",location="$LOCATION",type="$DEVICE_TYPE"} 1
# HELP network_device_cpu_usage CPU usage percentage
# TYPE network_device_cpu_usage gauge
network_device_cpu_usage{device="$DEVICE",location="$LOCATION",type="$DEVICE_TYPE"} $((RANDOM%80))
# HELP network_device_memory_usage Memory usage percentage
# TYPE network_device_memory_usage gauge
network_device_memory_usage{device="$DEVICE",location="$LOCATION",type="$DEVICE_TYPE"} $((RANDOM%90))
# HELP network_device_bandwidth_inbound Inbound bandwidth usage in bytes
# TYPE network_device_bandwidth_inbound counter
network_device_bandwidth_inbound{device="$DEVICE",location="$LOCATION",type="$DEVICE_TYPE",interface="wan1"} $((RANDOM%1000000000))
# HELP network_device_bandwidth_outbound Outbound bandwidth usage in bytes
# TYPE network_device_bandwidth_outbound counter
network_device_bandwidth_outbound{device="$DEVICE",location="$LOCATION",type="$DEVICE_TYPE",interface="wan1"} $((RANDOM%500000000))
# HELP network_device_packet_loss Packet loss percentage
# TYPE network_device_packet_loss gauge
network_device_packet_loss{device="$DEVICE",location="$LOCATION",type="$DEVICE_TYPE"} $(awk -v n=$RANDOM 'BEGIN{printf "%.2f", n/327.67}')
# HELP network_device_temperature_celsius Device temperature in Celsius
# TYPE network_device_temperature_celsius gauge
network_device_temperature_celsius{device="$DEVICE",location="$LOCATION",type="$DEVICE_TYPE",sensor="cpu"} $((40 + RANDOM%30))
# HELP network_device_interface_status Interface status (1=up, 0=down)
# TYPE network_device_interface_status gauge
network_device_interface_status{device="$DEVICE",location="$LOCATION",type="$DEVICE_TYPE",interface="eth0"} 1
network_device_interface_status{device="$DEVICE",location="$LOCATION",type="$DEVICE_TYPE",interface="eth1"} 1
network_device_interface_status{device="$DEVICE",location="$LOCATION",type="$DEVICE_TYPE",interface="wlan0"} $((RANDOM%2))
# HELP network_device_uptime_seconds Device uptime in seconds
# TYPE network_device_uptime_seconds counter
network_device_uptime_seconds{device="$DEVICE",location="$LOCATION",type="$DEVICE_TYPE"} $(( ( $(date +%s) - 1609459200 ) + (RANDOM%2592000) ))
# HELP network_device_connected_clients Number of connected wireless clients
# TYPE network_device_connected_clients gauge
network_device_connected_clients{device="$DEVICE",location="$LOCATION",type="$DEVICE_TYPE",ssid="Store-WiFi"} $((RANDOM%50))
# HELP network_device_dhcp_leases Number of active DHCP leases
# TYPE network_device_dhcp_leases gauge
network_device_dhcp_leases{device="$DEVICE",location="$LOCATION",type="$DEVICE_TYPE",pool="main"} $((20 + RANDOM%30))
# HELP network_device_ports_total Total number of ports
# TYPE network_device_ports_total gauge
network_device_ports_total{device="$DEVICE",location="$LOCATION",type="$DEVICE_TYPE"} $([ "$DEVICE_TYPE" = "router" ] && echo "8" || echo "24")
# HELP network_device_ports_up Number of active ports
# TYPE network_device_ports_up gauge
network_device_ports_up{device="$DEVICE",location="$LOCATION",type="$DEVICE_TYPE"} $([ "$DEVICE_TYPE" = "router" ] && echo $((RANDOM%8 + 1)) || echo $((RANDOM%24 + 1)))
EOF
)
  # Use -N flag to close connection after sending response
  echo -e "HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\n\r\n$RESPONSE" | nc -l -N -p "$PORT"
  # Small delay to prevent high CPU usage
  sleep 0.1
done