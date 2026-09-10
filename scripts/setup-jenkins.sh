#!/usr/bin/env bash

# 1. Limpa todas as referências anteriores do repositório e chaves quebradas
sudo rm -f /etc/apt/sources.list.d/jenkins.list
sudo rm -f /usr/share/keyrings/jenkins-keyring.asc
sudo rm -f /etc/apt/trusted.gpg.d/jenkins*

# 2. Atualiza os pacotes básicos e instala dependências de download
sudo apt-get update -y
sudo apt-get install -y curl wget openjdk-21-jre git ca-certificates gnupg

# 3. Baixa e adiciona a chave GPG atualizada do Jenkins
sudo mkdir -p /usr/share/keyrings
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null

# 4. Adiciona o repositório correto
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null

# 5. Atualiza os repositórios com a nova chave e instala o Jenkins
sudo apt-get update -y
sudo apt-get install -y jenkins

# 6. Instala o Node.js LTS
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt-get install -y nodejs

# 7. Habilita e inicia o serviço do Jenkins
sudo systemctl enable jenkins
sudo systemctl start jenkins


