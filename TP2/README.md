# TP2 - GitHub Actions CI/CD et Quality Gate


Mon application est automatiquement testée, construite et déployée à chaque commit.

## Questions et Réponses

## 2-1 What are testcontainers?

Les testcontainers sont des bibliothèques Java qui permettent de lancer des conteneurs Docker pendant les tests. Dans mon projet, j'utilise un conteneur PostgreSQL pour simuler une vraie base de données pendant mes tests d'intégration.

Ça me permet de tester mon application dans un environnement proche de la production sans avoir besoin d'installer PostgreSQL en local. Mes tests sont plus fiables car ils utilisent exactement la même config que la production.

Les testcontainers démarrent automatiquement un conteneur PostgreSQL avant chaque test d'intégration et le suppriment après, donc j'ai toujours un environnement propre pour chaque test.

## 2-2 For what purpose do we need to use secured variables?

Les variables sécurisées sont nécessaires pour protéger mes informations sensibles comme les mots de passe, les tokens d'API ou les clés privées. Ça évite d'exposer ces données dans mon code source qui est public sur GitHub.

Si je mettais mes credentials directement dans le fichier YAML du workflow, n'importe qui ayant accès au repo pourrait les voir et les utiliser. Avec les secrets GitHub, les valeurs sont chiffrées et ne sont jamais affichées dans les logs ou l'interface.

C'est une bonne pratique de sécurité essentielle pour éviter qu'on vole mes credentials ou qu'on accède à mes services externes comme Docker Hub ou SonarCloud sans autorisation.

## 2-3 Why did we put needs: test-backend on this job?

La directive `needs: test-backend` crée une dépendance entre les jobs. Mon job `build-and-push-docker-image` ne s'exécute que si le job `test-backend` a réussi.

Ça évite de construire et publier mes images Docker si les tests ont échoué. Je ne veux pas déployer du code qui ne fonctionne pas ou qui contient des bugs. C'est une étape importante du contrôle qualité : je ne publie que ce qui est testé et validé.

Sans cette dépendance, les jobs s'exécuteraient en parallèle et je pourrais publier des images avec du code cassé. C'est une règle fondamentale du CI/CD : ne jamais déployer du code qui n'a pas passé les tests.

## 2-4 For what purpose do we need to push docker images?

Pousser mes images Docker sur Docker Hub les rend disponibles pour le déploiement. Une fois que mes images sont publiées, je peux les télécharger et les utiliser sur n'importe quel serveur.

Ça facilite le déploiement car je n'ai pas besoin de reconstruire l'image sur chaque machine. Je peux simplement faire un `docker pull` pour récupérer la dernière version de l'image et la lancer. C'est particulièrement utile pour le déploiement automatisé avec Ansible ou d'autres outils.

De plus, Docker Hub me permet de versionner mes images (avec des tags comme `latest`, `v1.0`, etc.) et de gérer différentes versions de mon application. C'est essentiel pour le Continuous Deployment où chaque commit peut générer une nouvelle version déployable.

