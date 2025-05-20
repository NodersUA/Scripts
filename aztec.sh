#!/bin/bash
set -e

# Створення директорії
mkdir -p aztek && cd aztek

# Введення змінних
echo "Введіть ваш приватний ключ Ethereum EVM:"
read -p "" PRIV_KEY
echo "Введіть ваш публічний адрес EVM:"
read -p "" ADDRESS
echo "Введіть Eth Sepolia RPC URL:"
read -p "" SEPOLIA_RPC
echo "Введіть BEACON Sepolia URL:"
read -p "" BEACON_RPC

# Отримання зовнішнього IP автоматично
SERVER_IP=$(curl -4 ifconfig.me)

# Створення файлу .env
cat <<EOF > .env
PRIV_KEY=$PRIV_KEY
ADDRESS=$ADDRESS
SEPOLIA_RPC=$SEPOLIA_RPC
BEACON_RPC=$BEACON_RPC
SERVER_IP=$SERVER_IP
EOF

# Створення файлу docker-compose.yml
cat <<EOF > docker-compose.yml
version: "3.8"

services:
  aztec:
    image: aztecprotocol/aztec:0.85.0-alpha-testnet.5
    container_name: aztec
    environment:
      ETHEREUM_HOSTS: "\${SEPOLIA_RPC}"
      L1_CONSENSUS_HOST_URLS: "\${BEACON_RPC}"
      DATA_DIRECTORY: /data
      VALIDATOR_PRIVATE_KEY: "\${PRIV_KEY}"
      P2P_IP: "\${SERVER_IP}"
      LOG_LEVEL: debug
    entrypoint: >
      sh -c 'node --no-warnings /usr/src/yarn-project/aztec/dest/bin/index.js start --network alpha-testnet --node --archiver --sequencer --sequencer.validatorPrivateKey \${PRIV_KEY} --sequencer.coinbase \${ADDRESS} --p2p.p2pIp \${SERVER_IP}'
    ports:
      - 40400:40400/tcp
      - 40400:40400/udp
      - 8080:8080
    volumes:
      - ./data:/data
    restart: unless-stopped
    network_mode: host
EOF

# Запуск контейнера та виведення логів
docker compose up -d && docker logs -f aztec
