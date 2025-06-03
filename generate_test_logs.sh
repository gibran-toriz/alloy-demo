#!/bin/bash

# Create log directory if it doesn't exist
mkdir -p /tmp/router-logs
mkdir -p /tmp/switch-logs
mkdir -p /tmp/pos-logs
mkdir -p /tmp/server-logs

# Generate test logs for router
echo "$(date -u +'%Y-%m-%dT%H:%M:%S.%NZ') [INFO] Router core-router-01 started with high CPU usage (94%)" >> /tmp/router-logs/network-core.log

echo "$(date -u +'%Y-%m-%dT%H:%M:%S.%NZ') [WARN] High packet loss (15.2%) detected on interface eth0" >> /tmp/router-logs/network-core.log

# Generate test logs for switch
echo "$(date -u +'%Y-%m-%dT%H:%M:%S.%NZ') [INFO] Switch switch-01 port 1/1/1 up (1Gbps full-duplex)" >> /tmp/switch-logs/switch-core.log

echo "$(date -u +'%Y-%m-%dT%H:%M:%S.%NZ') [ERROR] Switch switch-01 BPDU guard on port 1/1/2: Inconsistent port type" >> /tmp/switch-logs/switch-core.log

# Generate test logs for POS
echo "$(date -u +'%Y-%m-%dT%H:%M:%S.%NZ') [INFO] POS terminal POS-01 started new transaction: $12.50" >> /tmp/pos-logs/pos-core.log

echo "$(date -u +'%Y-%m-%dT%H:%M:%S.%NZ') [ERROR] POS terminal POS-01: Payment gateway timeout" >> /tmp/pos-logs/pos-core.log

# Generate test logs for server
echo "$(date -u +'%Y-%m-%dT%H:%M:%S.%NZ') [INFO] Server app-01: Starting application service" >> /tmp/server-logs/server-core.log

echo "$(date -u +'%Y-%m-%dT%H:%M:%S.%NZ') [WARN] Server app-01: High memory usage (87%)" >> /tmp/server-logs/server-core.log

echo "Test logs generated successfully!"
