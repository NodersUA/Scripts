#!/bin/bash

curl -s https://raw.githubusercontent.com/NodersUA/Scripts/main/logo.sh | bash
echo "==================================================="
sleep 2

# Update the repositories and developer packages
sudo apt-get update && sudo apt-get install -y --no-install-recommends tzdata libprotobuf-dev ca-certificates build-essential libssl-dev libclang-dev pkg-config openssl protobuf-compiler git clang cmake -y

# Open ports
ufw allow 9000
ufw allow 9184

# Install Rust
sudo curl https://sh.rustup.rs -sSf | sh -s -- -y
source $HOME/.cargo/env

# Create a directory for database, genesis.blob, fullnode.yaml
cd && mkdir $HOME/.sui

# Clone GitHub SUI repository
cd $HOME
git clone https://github.com/MystenLabs/sui.git
cd sui
git remote add upstream https://github.com/MystenLabs/sui
git fetch upstream
git checkout --track upstream/testnet

# Make a copy of fullnode.yaml and update path to db and genesis state file.
cp $HOME/sui/crates/sui-config/data/fullnode-template.yaml $HOME/.sui/fullnode.yaml

sudo tee /root/.sui/fullnode.yaml > /dev/null << END

# Update this value to the location you want Sui to store its database
db-path: "/root/.sui/db"

network-address: "/dns/localhost/tcp/8080/http"
metrics-address: "0.0.0.0:9184"
# this address is also used for web socket connections
json-rpc-address: "0.0.0.0:9000"
enable-event-processing: true

genesis:
  # Update this to the location of where the genesis file is stored
  genesis-file-location: "/root/.sui/genesis.blob"

authority-store-pruning-config:
  num-latest-epoch-dbs-to-retain: 3
  epoch-db-pruning-period-secs: 3600
  num-epochs-to-retain: 1
  max-checkpoints-in-batch: 200
  max-transactions-in-batch: 1000
  use-range-deletion: true

p2p-config:
  seed-peers:
   - address: "/dns/sui-rpc-pt.testnet-pride.com/udp/8084"
     peer-id: 0b10182585ae4a305721b1823ea5a9c3ce7d6ac4b4a8ce35fe96d9914c8fcb73
   - address: "/dns/sui-rpc-pt2.testnet-pride.com/udp/8084"
     peer-id: bf45f2bd2bbc4c2d53d10c05c96085d4ef18688af04649d6e65e1ebad1716804
   - address: "/dns/sui-rpc-testnet.bartestnet.com/udp/8084"
   - address: "/ip4/38.242.197.20/udp/8080"
   - address: "/ip4/178.18.250.62/udp/8080"
   - address: "/ip4/162.55.84.47/udp/8084"
   - address: "/dns/wave-3.testnet.n1stake.com/udp/8084"
END

# Download Genesis
wget -P $HOME/.sui https://github.com/MystenLabs/sui-genesis/raw/main/testnet/genesis.blob

# Build SUI binaries
cargo build --release -p sui-node -p sui
mv $HOME/sui/target/release/sui-node /usr/local/bin/
mv $HOME/sui/target/release/sui /usr/local/bin/

# Create Service file for SUI Node
echo "[Unit]
Description=Sui Node
After=network.target

[Service]
User=$USER
Type=simple
ExecStart=/usr/local/bin/sui-node --config-path $HOME/.sui/fullnode.yaml
Restart=on-failure
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target" > $HOME/suid.service

mv $HOME/suid.service /etc/systemd/system/

ufw allow 9000
ufw allow 9184

# Start the node
sudo systemctl daemon-reload
sudo systemctl enable suid
sudo systemctl start suid
journalctl -u suid -f
