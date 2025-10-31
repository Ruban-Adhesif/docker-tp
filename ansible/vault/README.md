# Ansible Vault - Configuration sécurisée

Ce projet utilise Ansible Vault pour chiffrer les données sensibles (clé SSH privée).

## Architecture

- Ansible dans Docker : Exécution d'Ansible via un conteneur Docker
- Ansible Vault : Chiffrement des secrets avec AES-256
- Déploiement simplifié : Ne redémarre que le backend API

## Configuration

### 1. Chiffrer votre clé SSH

```bash
cd ansible
ansible-vault encrypt_string \
  --vault-password-file vault/.vault_pass \
  "$(cat data/id_rsa)" \
  --name "ssh_private_key" \
  > vault/secrets.yml
```

### 2. Créer le mot de passe vault

```bash
echo "votre_mot_de_passe_secret" > ansible/vault/.vault_pass
chmod 600 ansible/vault/.vault_pass
```

### 3. Ajouter le mot de passe dans GitHub Secrets

Dans GitHub → Settings → Secrets → Actions, ajoutez :
- `ANSIBLE_VAULT_PASSWORD` : votre mot de passe vault
- `SSH_PRIVATE_KEY` : votre clé SSH (fallback si vault échoue)

## Utilisation

### Déploiement local

```bash
cd ansible
docker build -t ansible-runner:latest .
docker run --rm \
  -v $(pwd):/ansible \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -e ANSIBLE_VAULT_PASSWORD="votre_mot_de_passe" \
  ansible-runner:latest \
  sh -c "echo 'votre_mot_de_passe' > /tmp/vault_pass && \
        ansible-vault decrypt --vault-password-file /tmp/vault_pass vault/secrets.yml && \
        grep -A 1000 'ssh_private_key:' vault/secrets.yml | tail -n +2 | \
        sed '1d' | sed '1d' > /tmp/id_rsa && \
        chmod 600 /tmp/id_rsa && \
        ansible-playbook -i inventories/setup.yml restart-backend.yml \
          --extra-vars 'ansible_ssh_private_key_file=/tmp/id_rsa'"
```

### Déploiement automatique

Le workflow GitHub Actions se déclenche automatiquement à chaque push sur `main` ou `master`.

## Structure

```
ansible/
├── Dockerfile              # Image Docker pour Ansible
├── restart-backend.yml    # Playbook simplifié (redémarre seulement le backend)
├── vault/
│   ├── secrets.yml        # Clé SSH chiffrée avec Ansible Vault
│   └── .vault_pass.example
└── scripts/
    └── encrypt-ssh-key.sh # Script d'aide pour chiffrer
```

## Sécurité

- Clé SSH chiffrée avec AES-256
- Mot de passe vault non commité dans git
- Utilisation de secrets GitHub Actions
- Exécution dans un conteneur Docker isolé

## Important

- Ne commitez JAMAIS `.vault_pass` dans git
- Ne commitez JAMAIS `secrets.yml.decrypted` dans git
- Ne commitez JAMAIS `data/id_rsa` dans git
- Utilisez toujours `ansible-vault` pour manipuler les secrets
