#!/bin/bash

sudo su

setenforce 0
systemctl stop firewalld

yum install httpd -y
systemctl start httpd
systemctl enable httpd

yum install tomcat tomcat-webapps tomcat-admin-webapps -y
systemctl start tomcat
systemctl enable tomcat

chmod 777 /var/log/tomcat
chmod 777 /var/log/tomcat/*


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

cat > docker-compose.yaml<<EOF
version: '3.2'
services:
    node-exporter:
        image: prom/node-exporter
        volumes:
            - /proc:/host/proc:ro
            - /sys:/host/sys:ro
            - /:/rootfs:ro
        command:
            - --path.procfs=/host/proc
            - --path.sysfs=/host/sys
            - --collector.filesystem.ignored-mount-points
            - ^/(sys|proc|dev|host|etc|rootfs/var/lib/docker/containers|rootfs/var/lib/docker/overlay2|rootfs/run/docker/netns|rootfs/var/lib/docker/aufs)($$|/)
        ports:
            - 9100:9100
        restart: always
        deploy:
            mode: global
EOF

docker-compose up -d