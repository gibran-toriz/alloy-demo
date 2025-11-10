#!/bin/bash

NOMBRE_CONTENEDOR="ram_simulator"

echo "🔁 Iniciando contenedor: $NOMBRE_CONTENEDOR"
docker start "$NOMBRE_CONTENEDOR"

if [ $? -eq 0 ]; then
  echo "✅ Contenedor '$NOMBRE_CONTENEDOR' iniciado correctamente."
else
  echo "❌ Error al iniciar el contenedor '$NOMBRE_CONTENEDOR'."
fi