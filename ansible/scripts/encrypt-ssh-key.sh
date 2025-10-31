#!/bin/bash

# Script pour chiffrer la clé SSH avec Ansible Vault

VAULT_PASSWORD_FILE="vault/.vault_pass"

if [ ! -f "$VAULT_PASSWORD_FILE" ]; then
    echo "Création du fichier de mot de passe vault..."
    read -sp "Entrez le mot de passe pour Ansible Vault: " VAULT_PASS
    echo ""
    echo "$VAULT_PASS" > "$VAULT_PASSWORD_FILE"
    chmod 600 "$VAULT_PASSWORD_FILE"
fi

echo "Chiffrement de la clé SSH..."
ansible-vault encrypt_string \
    --vault-password-file "$VAULT_PASSWORD_FILE" \
    "$(cat data/id_rsa)" \
    --name "ssh_private_key" \
    > vault/secrets.yml

echo "✅ Clé SSH chiffrée dans vault/secrets.yml"
