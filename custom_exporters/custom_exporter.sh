#!/bin/bash
PORT=9200
REGION=${REGION:-region1}
LOCATION=${LOCATION:-store-1}
PROBLEM_MODE=${PROBLEM_MODE:-healthy}

echo "Starting custom exporter on port $PORT, region: $REGION, location: $LOCATION, mode: $PROBLEM_MODE"
while true; do
  if [ "$PROBLEM_MODE" = "problem" ]; then
    TEMP=95
  else
    TEMP=$(shuf -i 40-90 -n 1)
  fi
  RESPONSE=$(cat <<EOF
HTTP/1.1 200 OK
Content-Type: text/plain

# HELP custom_temperature Temperature in Celsius
# TYPE custom_temperature gauge
custom_temperature{region="$REGION",location="$LOCATION"} $TEMP

EOF
)
  echo -e "$RESPONSE" | nc -l -p "$PORT" -q 0
  echo "Served metrics, restarting listener..."
  sleep 1
done