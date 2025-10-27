#!/bin/bash

# Script de déploiement pour GitHub Actions

set -e

echo "🚀 Starting deployment..."

# Configuration
SERVER_HOST="ruben.bensais--rueda.takima.cloud"
SERVER_USER="admin"
SSH_KEY="$HOME/.ssh/id_rsa"

# Fonction pour exécuter des commandes sur le serveur
run_remote() {
    ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no "$SERVER_USER@$SERVER_HOST" "$1"
}

# Fonction pour copier des fichiers sur le serveur
copy_to_server() {
    scp -i "$SSH_KEY" -o StrictHostKeyChecking=no -r "$1" "$SERVER_USER@$SERVER_HOST:$2"
}

echo "📦 Installing Ansible collections..."
ansible-galaxy collection install community.docker

echo "🔧 Deploying application..."
cd ansible
ansible-playbook -i inventories/setup.yml playbook.yml --extra-vars "ansible_ssh_private_key_file=$SSH_KEY"

echo "⏳ Waiting for services to start..."
sleep 30

echo "🔍 Verifying deployment..."
if curl -f "http://$SERVER_HOST/actuator/health"; then
    echo "✅ Deployment successful!"
    echo "🌐 API is available at: http://$SERVER_HOST"
    echo "📊 Students: http://$SERVER_HOST/students"
    echo "🏢 Departments: http://$SERVER_HOST/departments"
else
    echo "❌ Deployment verification failed!"
    exit 1
fi
