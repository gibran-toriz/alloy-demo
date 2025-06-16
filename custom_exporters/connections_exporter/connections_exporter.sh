#!/bin/bash

PORT=9701
INTERVAL=5
CONNECTIONS_FILE="/tmp/connections_metrics.prom"

while true; do
  > $CONNECTIONS_FILE

  # Exporter metric header
  echo "# HELP node_graph_edges Simulated connection edges between nodes" >> $CONNECTIONS_FILE
  echo "# TYPE node_graph_edges gauge" >> $CONNECTIONS_FILE

  # Get all running container names that follow the naming pattern
  NODE_CONTAINERS=$(docker ps --format '{{.Names}}' | grep -E '^(server|pos)[0-9]+$')

  for SRC in $NODE_CONTAINERS; do
    if [[ "$SRC" == server* ]]; then
      for DST in $NODE_CONTAINERS; do
        if [[ "$SRC" != "$DST" && "$DST" == server* ]]; then
          echo "node_graph_edges{id=\"${SRC}_${DST}_database\", source=\"$SRC\", target=\"$DST\", type=\"database\"} 1" >> $CONNECTIONS_FILE
        fi
      done
    elif [[ "$SRC" == pos* ]]; then
      echo "node_graph_edges{id=\"${SRC}_printer\", source=\"$SRC\", target=\"printer-${SRC}\", type=\"printer\"} 1" >> $CONNECTIONS_FILE
      echo "node_graph_edges{id=\"${SRC}_scanner\", source=\"$SRC\", target=\"scanner-${SRC}\", type=\"scanner\"} 1" >> $CONNECTIONS_FILE
      echo "node_graph_edges{id=\"${SRC}_server1\", source=\"$SRC\", target=\"server1\", type=\"backend\"} 1" >> $CONNECTIONS_FILE
    fi
  done

  # Serve metrics
  { echo -ne "HTTP/1.1 200 OK\r\nContent-Type: text/plain\r\n\r\n"; cat $CONNECTIONS_FILE; } | nc -l -p $PORT -q 1

  sleep $INTERVAL
done