#!/bin/bash

NOMBRE_CONTENEDOR="ram_simulator"

echo "🔁 Deteniendo contenedor: $NOMBRE_CONTENEDOR"
docker stop "$NOMBRE_CONTENEDOR"

if [ $? -eq 0 ]; then
  echo "✅ Contenedor '$NOMBRE_CONTENEDOR' detenido correctamente."
else
  echo "❌ Error al detener el contenedor '$NOMBRE_CONTENEDOR'."
fi