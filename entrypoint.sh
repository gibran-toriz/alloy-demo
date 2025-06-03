#!/bin/bash
# entrypoint.sh: Dynamically generate supervisord.conf for the correct exporter based on env vars
set -e

SUPERVISOR_CONF=/etc/supervisord.conf

cat > $SUPERVISOR_CONF <<EOF
[supervisord]
nodaemon=true
EOF

# Always start Alloy
cat >> $SUPERVISOR_CONF <<EOF
[program:alloy]
command=/usr/bin/alloy run /etc/alloy/config.river
autorestart=true
user=root
stdout_logfile=/tmp/alloy_stdout.log
stderr_logfile=/tmp/alloy_stderr.log
EOF

# Decide which exporter to run
case "$NODE_TYPE" in
  server)
    cat >> $SUPERVISOR_CONF <<EOF
[program:node_exporter]
command=/usr/bin/prometheus-node-exporter --web.listen-address=:9100 --collector.disable-defaults --collector.cpu --collector.meminfo --collector.loadavg --collector.uname
autorestart=true
user=root
environment=NODE_TYPE=%(ENV_NODE_TYPE)s
EOF
    ;;
  pos)
    cat >> $SUPERVISOR_CONF <<EOF
[program:retail_pos_exporter]
command=/bin/bash /opt/custom_exporters/retail_pos_exporter.sh 9300
autorestart=true
user=root
environment=NODE_TYPE=%(ENV_NODE_TYPE)s
EOF
    ;;
  router)
    # Establecer valor predeterminado para DEVICE_TYPE si no está definido
    if [ -z "$DEVICE_TYPE" ]; then
      DEVICE_TYPE="unknown"
    fi
    
    cat >> $SUPERVISOR_CONF <<EOF
[program:network_device_exporter_router]
command=/bin/bash /opt/custom_exporters/network_device_exporter.sh 9400
autorestart=true
user=root
environment=NODE_TYPE=${NODE_TYPE},DEVICE_TYPE=${DEVICE_TYPE}
EOF
    ;;
  switch)
    # Establecer valor predeterminado para DEVICE_TYPE si no está definido
    if [ -z "$DEVICE_TYPE" ]; then
      DEVICE_TYPE="unknown"
    fi
    
    cat >> $SUPERVISOR_CONF <<EOF
[program:network_device_exporter_switch]
command=/bin/bash /opt/custom_exporters/network_device_exporter.sh 9401
autorestart=true
user=root
environment=NODE_TYPE=${NODE_TYPE},DEVICE_TYPE=${DEVICE_TYPE}
EOF
    ;;
  custom)
    cat >> $SUPERVISOR_CONF <<EOF
[program:custom_exporter]
command=/bin/bash /opt/custom_exporters/custom_exporter.sh
autorestart=true
user=root
environment=NODE_TYPE=%(ENV_NODE_TYPE)s
EOF
    ;;
  *)
    echo "Unknown NODE_TYPE: $NODE_TYPE" >&2
    exit 1
    ;;
esac

exec /usr/bin/supervisord -c $SUPERVISOR_CONF
