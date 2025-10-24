# TP1 - Application 3-Tiers avec Docker

## Résumé

Ce projet implémente une architecture 3-tiers complète utilisant Docker et Docker Compose :
- **Base de données** : PostgreSQL avec volumes persistants
- **Backend** : API Java Spring Boot avec build multistage
- **Frontend** : Serveur Apache HTTP comme reverse proxy

L'application est conteneurisée et déployable avec une seule commande `docker compose up`.

## Questions et Réponses

## 1-1 For which reason is it better to run the container with a flag -e to give the environment variables rather than put them directly in the Dockerfile?

Il vaut mieux passer les variables d'environnement avec le flag `-e` au moment du `docker run` plutôt que de les écrire directement dans le Dockerfile. Ça évite d'avoir des mots de passe ou des informations sensibles enregistrées en clair dans le fichier ou dans l'image.

En plus, ça rend l'image plus flexible : on peut la réutiliser dans différents environnements en changeant juste les variables, sans avoir à reconstruire l'image à chaque fois. C'est donc plus propre, sécurisé et pratique.

## 1-2 Why do we need a volume to be attached to our postgres container?

On a besoin d'un volume pour que les données de la base de données soient sauvegardées même si le conteneur est supprimé. Sans volume, tout ce qui est dans Postgres disparaît dès qu'on arrête ou qu'on supprime le conteneur. Avec un volume, les données sont stockées sur le disque de la machine hôte, donc elles persistent et on peut redémarrer ou recréer le conteneur sans rien perdre.

C'est indispensable pour une base de données, sinon elle serait vide à chaque redémarrage.

## 1-3 Document your database container essentials: commands and Dockerfile.

## 1-4 Why do we need a multistage build? And explain each step of this dockerfile.

On a besoin d'un multistage build pour séparer les étapes de compilation et d'exécution. Pendant la compilation, on a besoin du JDK (Java Development Kit) car il contient tout ce qu'il faut pour compiler le code Java, comme javac ou Maven. Mais une fois que l'application est compilée et qu'on a notre fichier .jar, on n'a plus besoin du JDK. Il suffit juste d'avoir le JRE (Java Runtime Environment) qui permet simplement d'exécuter le programme. 

En faisant un multistage build, on utilise une première image avec le JDK pour construire le projet et créer le .jar, puis une seconde image avec seulement le JRE, beaucoup plus légère, pour exécuter ce .jar. Ça rend l'image finale plus optimisée, plus sécurisée et plus rapide à déployer.

## 1-5 Why do we need a reverse proxy?

On a besoin d'un reverse proxy pour faire passer les requêtes des utilisateurs vers le bon serveur sans qu'ils accèdent directement au backend.

Ça permet de protéger l'application en cachant le backend, de mieux gérer le trafic si plusieurs services tournent derrière, et de centraliser tous les accès sur une seule adresse.

C'est aussi utile pour ajouter facilement des fonctionnalités comme le chiffrement HTTPS, la redirection, ou le filtrage des requêtes.

## 1-6 Why is docker-compose so important?

Docker-compose est important parce qu'il permet de gérer facilement plusieurs conteneurs qui fonctionnent ensemble. Au lieu de lancer chaque conteneur manuellement avec plein de paramètres, on définit tout dans un seul fichier `docker-compose.yml`. Avec une seule commande, je peux construire, démarrer, arrêter ou supprimer toute mon application (backend, base de données, serveur HTTP…). C'est plus rapide, plus propre, plus reproductible, et surtout plus proche de la façon dont une vraie application est déployée en entreprise.

## 1-7 Document docker-compose most important commands.

Voici les commandes Docker Compose qui sont le plus importantes :

- `docker compose up -d --build` : permet de construire et lancer tous les services en arrière-plan
- `docker compose down -v` : arrête et supprime les conteneurs, réseaux et volumes
- `docker compose ps` : affiche les services qui tournent
- `docker compose logs` : permet de montrer les logs d'un service (par exemple backend ou httpd)
- `docker compose exec` : permet d'entrer dans un conteneur en ligne de commande
- `docker compose restart` : permet de redémarrer un service spécifique
- `docker compose build` : permet de reconstruire les images sans lancer les conteneurs

Ces commandes suffisent pour gérer tout le cycle de vie de mon projet multi-conteneurs.

## 1-8 Document your docker-compose file.

Mon fichier `docker-compose.yml` définit les trois services de mon application :

- **database** : pour le conteneur PostgreSQL, qui stocke les données
- **backend** : pour l'API Java Spring Boot, qui communique avec la base
- **httpd** : pour le serveur Apache HTTP utilisé comme reverse proxy

J'ai aussi deux réseaux :
- `net-data` : pour relier backend et database
- `net-front` : pour relier httpd et backend

Et un volume `pgdata` pour sauvegarder les données de la base même après suppression des conteneurs. Grâce à ce fichier, je peux tout lancer d'un coup sans me soucier de l'ordre de démarrage ni des liens entre les services.

## 1-9 Document your publication commands and published images in dockerhub.

Pour publier mes images sur Docker Hub, j'ai d'abord vérifié qu'elles étaient bien construites localement avec `docker images`. Ensuite, je me suis connecté à mon compte Docker Hub avec : `docker login -u rubentp`, puis j'ai tagué chacune de mes images locales avec mon nom d'utilisateur Docker Hub :

```bash
docker tag my-3tier-database:latest rubentp/my-database:1.0
docker tag my-3tier-backend:latest  rubentp/simpleapi:1.0
docker tag my-3tier-httpd:latest    rubentp/http-server:1.0
```

Enfin, je les ai publiées en ligne :

```bash
docker push rubentp/my-database:1.0
docker push rubentp/simpleapi:1.0
docker push rubentp/http-server:1.0
```

## 1-10 Why do we put our images into an online repo?

On met nos images dans un dépôt en ligne pour plusieurs raisons :

- **Partage** : ça permet à d'autres développeurs ou membres de l'équipe de récupérer facilement la même image sans devoir la reconstruire
- **Déploiement simplifié** : les serveurs de production peuvent directement télécharger l'image depuis le dépôt pour la lancer
- **Versioning** : on peut gérer différentes versions (par exemple 1.0, 1.1, latest) sans casser les anciens déploiements
- **Sauvegarde et portabilité** : nos images ne dépendent plus d'une seule machine locale, elles sont stockées dans le cloud et peuvent être utilisées n'importe où

En résumé, c'est plus collaboratif, sécurisé et pratique pour le déploiement et la maintenance du projet.