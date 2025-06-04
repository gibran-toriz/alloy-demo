FROM debian:bullseye

# Instala dependencias base
RUN apt-get update && apt-get install -y \
    curl \
    gnupg2 \
    supervisor \
    prometheus-node-exporter \
    netcat-openbsd

# Agrega la clave GPG y el repositorio de Grafana para instalar Alloy
RUN mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://apt.grafana.com/gpg.key | gpg --dearmor -o /etc/apt/keyrings/grafana.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" > /etc/apt/sources.list.d/grafana.list && \
    apt-get update && apt-get install -y alloy && \
    apt-get clean

# Crea directorios necesarios
RUN mkdir -p /etc/alloy /var/log/hostlogs /opt/custom_exporters /data-alloy /etc/supervisor/conf.d

# Copia archivos
ARG NODE_TYPE=pos
COPY configs/${NODE_TYPE}.river /etc/alloy/config.river

# Copia los scripts de exportadores
COPY custom_exporters/*.sh /opt/custom_exporters/

# Copia el script de entrypoint
COPY entrypoint.sh /opt/entrypoint.sh

# Da permisos a los scripts
RUN chmod +x /opt/custom_exporters/*.sh /opt/entrypoint.sh

# Set the entrypoint
ENTRYPOINT ["/opt/entrypoint.sh"]

# Expone puertos
# 9100: Node Exporter
# 9200: Custom Exporter
# 9300-9301: Retail POS Exporters
# 9400-9401: Network Device Exporters
# 9500: Switch Exporter
# 9600-9601: Server Exporters
# 12345: Alloy UI
EXPOSE 9100 9200 9300-9301 9400-9401 9500 9600-9601 12345

# Comando por defecto
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]