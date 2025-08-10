#!/bin/bash

# Define o local de instalação
INSTALL_DIR="/usr/local/bin"
DOCKER_COMPOSE_BIN="$INSTALL_DIR/docker-compose"

echo "Buscando o último release do Docker Compose..."

# Pega o URL do último release usando a API do GitHub
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)
LATEST_RELEASE_URL=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | jq -r '.assets[] | select(.name | contains("docker-compose-'"$OS"'-'"$ARCH"'")) | .browser_download_url')

if [ -z "$LATEST_RELEASE_URL" ]; then
    echo "Erro: Não foi possível encontrar o URL de download para a arquitetura do seu sistema."
    exit 1
fi

LATEST_RELEASE_URL_STR=($LATEST_RELEASE_URL)
LATEST_RELEASE_URL=${LATEST_RELEASE_URL_STR[0]}

echo "Baixando o Docker Compose da URL '$LATEST_RELEASE_URL'..."

# Baixa o binário
sudo curl -L "$LATEST_RELEASE_URL" -o "$DOCKER_COMPOSE_BIN"

if [ $? -ne 0 ]; then
    echo "Erro: Falha ao baixar o Docker Compose."
    exit 1
fi

echo "Definindo permissões de execução..."

# Torna o binário executável
sudo chmod +x "$DOCKER_COMPOSE_BIN"

if [ $? -ne 0 ]; then
    echo "Erro: Falha ao definir permissões de execução."
    exit 1
fi

echo "Docker Compose instalado/atualizado com sucesso!"

# Verifica a versão instalada
echo "Versão instalada:"
docker compose version
