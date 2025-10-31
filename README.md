# DevOps Training - Application 3-Tiers

Projet de formation DevOps implémentant une architecture 3-tiers complète avec Docker, CI/CD et déploiement automatisé.

## Architecture

L'application est composée de trois couches :

- **Base de données** : PostgreSQL avec volumes persistants
- **Backend** : API Java Spring Boot avec build multistage
- **Frontend** : Application Vue.js avec reverse proxy Nginx

## Structure du projet

```
├── TP1/          # Docker et Docker Compose
├── TP2/          # GitHub Actions CI/CD
├── TP3/          # Ansible et déploiement automatisé
├── ansible/      # Configuration Ansible
├── frontend/     # Application Vue.js
└── simpleapi/    # Backend Spring Boot
```

## TPs réalisés

### TP1 - Docker
Dockerisation complète de l'application avec Docker Compose. Mise en place d'une architecture 3-tiers avec volumes persistants, réseaux Docker et reverse proxy.

**Voir** : [TP1/README.md](TP1/README.md)

### TP2 - GitHub Actions
Pipeline CI/CD complet avec GitHub Actions. Tests automatiques, build Docker, publication sur Docker Hub et analyse de qualité avec SonarCloud.

**Voir** : [TP2/README.md](TP2/README.md)

### TP3 - Ansible
Déploiement automatisé avec Ansible. Configuration de rôles pour installer Docker, créer les réseaux et déployer les conteneurs. Intégration avec GitHub Actions pour le déploiement continu.

**Voir** : [TP3/README.md](TP3/README.md)

## Déploiement

L'application est déployée automatiquement sur le serveur à chaque push sur la branche `main` via GitHub Actions.

**URL de l'application** : http://ruben.bensais--rueda.takima.cloud

## Technologies utilisées

- **Docker** : Conteneurisation
- **Docker Compose** : Orchestration locale
- **GitHub Actions** : CI/CD
- **Ansible** : Déploiement automatisé
- **SonarCloud** : Analyse de qualité du code
- **PostgreSQL** : Base de données
- **Spring Boot** : Backend API
- **Vue.js** : Frontend
- **Nginx** : Reverse proxy

## Images Docker

Les images sont publiées sur Docker Hub :
- `rubbns/tp-devops-database`
- `rubbns/tp-devops-simple-api`
- `rubbns/tp-devops-frontend`