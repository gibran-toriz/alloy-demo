FROM debian:bullseye

# Install necessary dependencies including Docker CLI
RUN apt-get update && apt-get install -y \
  curl \
  ca-certificates \
  netcat-openbsd \
  docker.io \
  && apt-get clean

# Create working directory
WORKDIR /opt

# Copy the exporter script
COPY connections_exporter.sh /opt/connections_exporter.sh
RUN chmod +x /opt/connections_exporter.sh

# Expose port
EXPOSE 9701 12345

# Run the exporter
CMD ["/opt/connections_exporter.sh"]