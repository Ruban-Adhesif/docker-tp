# TP3 - Ansible - Déploiement Automatique

Mon application est maintenant déployée automatiquement avec Ansible sur mon serveur distant.

## Questions et Réponses

## 3-1 Document your inventory and base commands

Mon inventory est configuré dans `ansible/inventories/setup.yml`. Il contient la configuration de mon serveur de production avec l'utilisateur admin et le chemin vers ma clé SSH privée.

Voici les commandes de base que j'utilise :

**Tester la connexion :**
```bash
ansible all -i inventories/setup.yml -m ping
```

**Récupérer les facts du serveur :**
```bash
ansible all -i inventories/setup.yml -m setup -a "filter=ansible_distribution*"
```

**Exécuter une commande simple :**
```bash
ansible all -i inventories/setup.yml -m apt -a "name=apache2 state=absent" --become
```

L'inventory me permet de gérer mon serveur de production facilement. Je peux aussi créer des groupes pour organiser mes serveurs par rôle (database, frontend, backend, etc.).

## 3-2 Document your playbook

Mon playbook principal (`playbook.yml`) organise le déploiement de toute mon application. Il utilise plusieurs rôles pour structurer mon code :

- **docker** : Installation de Docker sur le serveur
- **network** : Création des réseaux Docker (backend et frontend)
- **db** : Déploiement du conteneur base de données PostgreSQL
- **app** : Déploiement du backend Spring Boot
- **proxy** : Déploiement du reverse proxy Apache

Chaque rôle a ses propres tâches dans `roles/[nom-role]/tasks/main.yml`. Ça rend mon code plus organisé et réutilisable. Je peux aussi ajouter des handlers pour redémarrer des services si nécessaire.

Mon playbook utilise `gather_facts: true` pour récupérer des informations sur le serveur, et `become: true` pour exécuter les commandes en tant qu'administrateur.

## 3-3 Document your docker_container tasks configuration

Pour déployer mes conteneurs Docker, j'utilise le module `community.docker.docker_container`. Voici comment j'ai configuré mes conteneurs :

**Base de données :**
- Image : `rubbns/tp-devops-database`
- Variables d'environnement : POSTGRES_DB, POSTGRES_USER, POSTGRES_PASSWORD
- Volume : Pour persister les données
- Réseau : my3tier_back
- Healthcheck : Vérifie que PostgreSQL est prêt

**Backend :**
- Image : `rubbns/tp-devops-simple-api`
- Variables d'environnement : POSTGRES_HOST, POSTGRES_PORT, POSTGRES_DB, POSTGRES_USER, POSTGRES_PASSWORD
- Réseaux : my3tier_back et my3tier_front (pour communiquer avec la DB et le proxy)
- Expose : Port 8080
- Restart policy : unless-stopped (redémarre automatiquement si le conteneur crash)

**Proxy :**
- Image : `rubbns/tp-devops-frontend` (qui contient le frontend + nginx)
- Published ports : 80:80 (expose le port 80 sur le serveur)
- Réseau : my3tier_front
- Configuration nginx : Redirige `/api/` vers le backend et sert le frontend sur `/`

La clé importante est d'utiliser les bons réseaux Docker pour que les conteneurs puissent communiquer entre eux. J'utilise aussi `pull: yes` pour m'assurer d'avoir toujours la dernière version de mes images.

## Continuous Deployment - Sécurité

**Est-ce vraiment sûr de déployer automatiquement chaque nouvelle image sur le hub ?**

Non, ce n'est pas totalement sûr. Si quelqu'un compromet mon compte Docker Hub ou si je push une image malveillante par erreur, elle sera automatiquement déployée en production. C'est risqué surtout si je n'ai pas de tests automatisés ou de validation.

**Que puis-je faire pour rendre ça plus sécurisé ?**

Plusieurs choses que j'ai mises en place :

1. **Quality Gate** : Mes tests doivent passer avant de publier l'image. Si les tests échouent, l'image n'est pas publiée.

2. **Tags de version** : Au lieu d'utiliser toujours `latest`, je peux utiliser des tags de version (`v1.0`, `v1.1`) et déployer seulement les versions validées.

3. **Approbation manuelle** : Ajouter une étape d'approbation avant le déploiement pour les versions critiques.

4. **Tests en staging** : Déployer d'abord sur un environnement de test avant la production.

5. **Rollback automatique** : Mettre en place un système de rollback si le healthcheck échoue après déploiement.

6. **Ansible Vault** : Chiffrer mes secrets (clés SSH, mots de passe) avec Ansible Vault pour protéger mes credentials.

## Going Further - Ansible Vault

J'ai amélioré mon déploiement en utilisant Ansible Vault pour chiffrer ma clé SSH privée. Au lieu de stocker la clé en clair dans mon repo GitHub, je l'ai chiffrée avec AES-256.

**Pourquoi utiliser Ansible Vault ?**

Ça permet de stocker mes secrets de manière sécurisée dans le repo. Même si quelqu'un accède au code, il ne peut pas voir ma clé SSH privée sans le mot de passe du vault.

**Comment ça fonctionne ?**

1. Je chiffre ma clé SSH avec `ansible-vault encrypt_string`
2. Je stocke le mot de passe dans GitHub Secrets
3. Mon workflow GitHub Actions déchiffre automatiquement la clé avant de l'utiliser
4. Je lance Ansible dans un conteneur Docker pour être sûr d'avoir les bonnes versions des outils

**Avantages :**
- Sécurité : Mes secrets ne sont jamais en clair
- Automatisation : Le déploiement reste entièrement automatique
- Isolation : Ansible dans Docker garantit un environnement reproductible
- Traçabilité : Tous les déploiements sont tracés dans GitHub Actions

C'est une solution "overkill" comme demandé, mais ça me permet d'apprendre les bonnes pratiques de sécurité en DevOps !
