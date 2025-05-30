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
COPY config.river /etc/alloy/config.river
COPY custom_exporters/custom_exporter.sh /opt/custom_exporters/custom_exporter.sh
COPY supervisord.conf /etc/supervisord.conf

# Da permisos
RUN chmod +x /opt/custom_exporters/custom_exporter.sh

# Expone puertos
EXPOSE 9100 9200 12345

# Comando por defecto
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisord.conf"]