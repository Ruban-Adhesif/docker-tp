#!/bin/bash

# Script de déploiement Ansible pour l'application 3-tiers

echo "🚀 Déploiement de l'application 3-tiers avec Ansible..."

# Installation des collections Ansible nécessaires
echo "📦 Installation des collections Ansible..."
ansible-galaxy collection install -r requirements.yml

# Vérification de la connectivité
echo "🔍 Vérification de la connectivité..."
ansible all -i inventories/setup.yml -m ping

# Déploiement de l'application
echo "🏗️ Déploiement de l'application..."
ansible-playbook -i inventories/setup.yml playbook.yml

echo "✅ Déploiement terminé !"
echo "🌐 Votre application est accessible sur : http://ruben.bensais--rueda.takima.cloud"
