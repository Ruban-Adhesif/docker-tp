# Déploiement Ansible - Application 3-Tiers

## Description

Ce projet contient la configuration Ansible pour déployer une application 3-tiers composée de :
- **Base de données** : PostgreSQL
- **Backend** : API Java Spring Boot  
- **Proxy** : Serveur HTTP Apache

## Structure

```
ansible/
├── playbook.yml              # Playbook principal
├── inventories/
│   └── setup.yml            # Configuration des serveurs
├── group_vars/
│   └── all.yml              # Variables globales
├── roles/
│   ├── docker/              # Installation de Docker
│   ├── network/             # Création des réseaux Docker
│   ├── db/                  # Déploiement de la base de données
│   ├── app/                 # Déploiement de l'application backend
│   └── proxy/               # Déploiement du proxy HTTP
├── requirements.yml          # Collections Ansible nécessaires
└── deploy.sh                # Script de déploiement automatisé
```

## Prérequis

1. **Ansible** installé sur votre machine locale
2. **Accès SSH** au serveur de déploiement
3. **Clé SSH** configurée dans `data/id_rsa`
4. **Images Docker** publiées sur Docker Hub :
   - `rubentp/my-database:1.0`
   - `rubentp/simpleapi:1.0`
   - `rubentp/http-server:1.0`

## Utilisation

### Déploiement automatique
```bash
cd ansible
./deploy.sh
```

### Déploiement manuel
```bash
# Installation des collections
ansible-galaxy collection install -r requirements.yml

# Test de connectivité
ansible all -i inventories/setup.yml -m ping

# Déploiement
ansible-playbook -i inventories/setup.yml playbook.yml
```

## Configuration

Les variables principales sont définies dans `group_vars/all.yml` :

- **Réseaux** : `my3tier_back` et `my3tier_front`
- **Images** : Vos images Docker Hub
- **Variables DB** : `db`, `usr`, `pwd`
- **Ports** : Backend sur 8080, Proxy sur 80

## Accès

Une fois déployé, l'application sera accessible sur :
- **URL publique** : `http://ruben.bensais--rueda.takima.cloud`
- **Port local** : `80` (redirigé vers le proxy)

## Rôles

### 1. Docker (`roles/docker/`)
- Installation de Docker CE
- Configuration des permissions utilisateur
- Installation du SDK Python Docker

### 2. Network (`roles/network/`)
- Création des réseaux Docker backend et frontend
- Isolation des services

### 3. Database (`roles/db/`)
- Création du volume PostgreSQL
- Déploiement du conteneur base de données
- Configuration des variables d'environnement
- Health check automatique

### 4. App (`roles/app/`)
- Attente de la disponibilité de la base de données
- Déploiement du backend Spring Boot
- Configuration des connexions réseau
- Health check automatique

### 5. Proxy (`roles/proxy/`)
- Attente de la disponibilité du backend
- Déploiement du serveur HTTP Apache
- Exposition du port 80
- Redirection du trafic vers le backend

## Dépannage

### Vérifier les conteneurs
```bash
ansible all -i inventories/setup.yml -m shell -a "docker ps"
```

### Vérifier les logs
```bash
ansible all -i inventories/setup.yml -m shell -a "docker logs backend"
ansible all -i inventories/setup.yml -m shell -a "docker logs database"
ansible all -i inventories/setup.yml -m shell -a "docker logs httpd"
```

### Redémarrer les services
```bash
ansible all -i inventories/setup.yml -m shell -a "docker restart backend"
```
