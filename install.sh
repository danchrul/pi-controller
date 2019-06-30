#!/bin/sh

apt-get install docker.io
docker volume create unifi-storage
docker volume create grafana-storage
docker volume create prometheus-storage

docker create   --name=unifi-controller   -e PUID=1000   -e PGID=1000   -p 3478:3478/udp   -p 10001:10001/udp   -p 8080:8080   -p 8081:8081   -p 8443:8443   -p 8843:8843   -p 8880:8880   -p 6789:6789   -v unifi-storage:/config   --restart unless-stopped   linuxserver/unifi-controller
docker start unifi-controller


wget https://github.com/prometheus/node_exporter/releases/download/v0.18.1/node_exporter-0.18.1.linux-arm64.tar.gz
tar xzf node_exporter-0.18.1.linux-arm64.tar.gz
sudo cp node-exporter.service /etc/systemd/system/node-exporter.service
sudo systemctl enable node-exporter
sudo systemctl restart node-exporter

cp /data/prometheus/prometheus.yml /var/lib/docker/volumes/prometheus-storage/_data/
docker create --name=prometheus -p 9090:9090 -v prometheus-storage:/prometheus-data prom/prometheus --config.file=/prometheus-data/prometheus.yml
docker start prometheus

docker create --name=grafana -e "GF_SECURITY_ADMIN_PASSWORD=pass" --volume "grafana-storage:/var/lib/grafana" -p 3000:3000 grafana/grafana
docker start grafana
