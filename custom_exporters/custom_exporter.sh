#!/bin/bash
PORT=9200
echo "Starting custom exporter on port $PORT"
while true; do
  RESPONSE=$(cat <<EOF
HTTP/1.1 200 OK
Content-Type: text/plain

# HELP custom_temperature Temperature in Celsius
# TYPE custom_temperature gauge
custom_temperature $(shuf -i 40-90 -n 1)

EOF
)
  echo -e "$RESPONSE" | nc -l -p "$PORT" -q 0
  echo "Served metrics, restarting listener..."
  sleep 1
done