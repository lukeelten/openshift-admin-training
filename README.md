# OpenShift Installation und Administration

## Kennen lernen

- Vorstellen des Dozenten
- Vorstellen der Teilnehmer
- Erfahrung mit OpenShift, Origin, OKD
- Erwartungen an den Kurs
- Themen über die man gerne Sprechen möchte



## Übersicht Themen und Ablauf

- Themen
- Zeitlicher Ablauf


## Einführung in die Konzepte von OpenShift
- Vergleich zu kubernetes
- Architektur
- TLS Node Erkennung
  
- Deployments & Deployment Configs
- Services
- Routes

- Persistent Volumes
- Persistent Volume Claims



## Konzeption & Installation eines OpenShift-Cluster
- Sizing
- DNS Einträge
- Welche Playbooks gibt es
- Wo findet man uninstall und update
- Wie kann man einzelne Rollen ausführen


- Vorsicht mit Metriken / Logging & Block Storage

## LDAP Anbindung & User Management

- LDAP Anbinding
- Identity Provider
- Htpasswd
- Deny All
- Allow All
- Diversere Social Logins
- Generic OpenID Connect
- LDAP
- Keystone (OpenStack Identity Provider)

https://docs.okd.io/3.11/architecture/additional_concepts/authorization.html#architecture-additional-concepts-authorization
https://docs.okd.io/3.11/architecture/additional_concepts/authorization.html#roles



## Cluster Updates & Scale Up
- Cluster Updates mit Node evakuieren
- System Updates
- Docker Updates
- Node ScaleUp
- Master ScaleUp (Vorsicht nur ungrade Zahlen)

## Persistent Storage mit Container Native Storage
- GlusterFS
- Container Native Storage
- Heketi
- NFS ist deprecated
- iSCSI

## Backup & Restore Konzepte
- Klasische snapshots
- etcd Backup
- Export der Cluster und Projekt Objekte

## Externe Image Registry
- Auslagern des Registry PV nach 
- Beispiel mit Nexus

## Security Concepts
- SELinux
- Non root container per default
- Block arbitrary images (kein docker hub)
- ---> https://docs.okd.io/3.11/admin_guide/image_policy.html
- scanning nach sicherheitslücken



## High Availability & Failover
- Hochverfügbarkeit des Cluster
- Hochverfügbarkeit von Applikationen
- Flaschenhälse
- Auto Scaling

## Best Practices
- Keine prod. Datenbank betreiben
- Infrastruktur as Code
- Audit Logs