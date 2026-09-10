#!/usr/bin/env bash

sudo apt-get update -y
sudo apt-get install -y curl git

# Instalação do Node.js
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt-get install -y nodejs