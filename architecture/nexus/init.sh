#!/bin/bash

yum -y update
yum -y install epel-release NetworkManager
yum -y install docker haveged nano git bind-utils traceroute
systemctl enable docker haveged NetworkManager
systemctl start docker haveged NetworkManager

curl -L "https://github.com/docker/compose/releases/download/1.23.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/bin/docker-compose
chmod +x /usr/bin/docker-compose

NEXUS=$(cat <<EOF
version: '3'

volumes:
  nexus:
    driver: local
  ldap:
    driver: local
  mariadb:
    driver: local

networks:
  keycloak:
    driver: bridge

services:
  nexus:
    restart: always
    image: sonatype/nexus3
    expose:
      - "8081"
      - "5000-5010"
    ports:
      - "8080:8081"
      - "5000-5010:5000-5010"
    volumes:
      - nexus:/nexus-data

  ldap:
    restart: always
    image: osixia/openldap
    volumes:
      - ldap:/var/lib/ldap
    environment:
      LDAP_ORGANISATION: "codecentric AG"
      LDAP_DOMAIN: "cc-openshift.de"
      LDAP_BASE_DN: ""
      LDAP_ADMIN_PASSWORD: "OpenShiftLdap"
      LDAP_READONLY_USER: "true"
      LDAP_READONLY_USER_USERNAME: "openshift"
      LDAP_READONLY_USER_PASSWORD: "OpenShiftLdap"
    ports:
      - 389:389
      - 636:636

  keycloak:
    restart: always
    image: jboss/keycloak:5.0.0
    environment:
      DB_VENDOR: MARIADB
      DB_ADDR: mariadb
      DB_DATABASE: keycloak
      DB_USER: keycloak
      DB_PASSWORD: 2jyG7e2dZ3e4QZxC
      KEYCLOAK_USER: admin
      KEYCLOAK_PASSWORD: password
      KEYCLOAK_HOSTNAME: sso.cc-openshift.de
    ports:
      - 80:8080
      - 443:8443
    depends_on:
      - mariadb
    networks:
      - keycloak

  mariadb:
    restart: always
    image: mariadb:10.3
    command: ["mysqld", "--collation-server=utf8mb4_unicode_ci", "--character-set-server=utf8mb4"]
    expose:
    - 3306
    volumes:
    - mariadb:/var/lib/mysql
    environment:
      MYSQL_ROOT_PASSWORD: 2jyG7e2dZ3e4QZxC
      MYSQL_DATABASE: keycloak
      MYSQL_USER: keycloak
      MYSQL_PASSWORD: 2jyG7e2dZ3e4QZxC
    networks:
    - keycloak
EOF
)
echo "$NEXUS" > /nexus.yml
docker-compose -f /nexus.yml -p nexus up -d


reboot