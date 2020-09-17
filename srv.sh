#!/bin/bash

sudo su

setenforce 0
systemctl stop firewalld

#------------------------------------------
#			DOCKER 
#------------------------------------------
curl -fsSL https://get.docker.com/ | sh
systemctl start docker
systemctl enable docker

#------------------------------------------
#		DOCKER COMPOSE
#------------------------------------------
curl -L "https://github.com/docker/compose/releases/download/1.23.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
export PATH=$PATH:/usr/local/bin/


#DOCKER .yaml
cat > docker-compose.yaml<<EOF
version: '3.2'
services:
    prometheus:
        image: prom/prometheus:latest
        volumes:
            - ./prometheus:/etc/prometheus/
        command:
            - --config.file=/etc/prometheus/prometheus.yml
        ports:
            - 9090:9090
        restart: always
    grafana:
        image: grafana/grafana
        depends_on:
            - prometheus
        ports:
            - 3000:3000
        volumes:
            - ./grafana:/var/lib/grafana
            - ./grafana/provisioning/:/etc/grafana/provisioning/
        restart: always
    blackbox:
        image: prom/blackbox-exporter:v0.10.0
        depends_on:
            - prometheus
        ports:
            - 9115:9115
        restart: always
EOF

mkdir prometheus
mkdir -p grafana/provisioning

chmod 777 grafana
chmod 777 grafana/*
cat > grafana/provisioning/grafana.ini<<EOF
datasources:
  - name: Graphite
    url: http://${srv_ext_IP}:3000
    user: admin
    secureJsonData:
      password: admin
EOF


#prometheus config 
#imported DB: 7587, 11623
cat > prometheus/prometheus.yml<<EOF
scrape_configs:
  - job_name: node
    scrape_interval: 5s
    static_configs:
    - targets: ['${int_IP}:9100']
  - job_name: blackbox
    metrics_path: /probe
    params:
      module: [http_2xx]
    static_configs:
      - targets:
          - http://${ext_IP}:8080
          - https://onliner.by
    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - source_labels: [__param_target]
        target_label: instance
      - target_label: __address__
        replacement: ${srv_ext_IP}:9115
EOF

docker-compose up -d





