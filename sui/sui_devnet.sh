#!/bin/bash

curl -s https://raw.githubusercontent.com/NodersUA/Scripts/main/logo.sh | bash
echo "==================================================="
sleep 2

# Update the repositories and developer packages
sudo apt-get update && sudo apt-get install -y --no-install-recommends tzdata libprotobuf-dev ca-certificates build-essential libssl-dev libclang-dev pkg-config openssl protobuf-compiler git clang cmake -y

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
git checkout --track upstream/devnet

# Make a copy of fullnode.yaml and update path to db and genesis state file.
cp crates/sui-config/data/fullnode-template.yaml $HOME/.sui/fullnode.yaml
sed -i.bak "s|db-path:.*|db-path: \"$HOME\/.sui\/db\"| ; s|genesis-file-location:.*|genesis-file-location: \"$HOME\/.sui\/genesis.blob\"| ; s|127.0.0.1|0.0.0.0|" $HOME/.sui/fullnode.yaml

# Download Genesis
wget -P $HOME/.sui https://github.com/MystenLabs/sui-genesis/raw/main/devnet/genesis.blob

# Build SUI binaries
cargo build --release -p sui-node -p sui
mv ~/sui/target/release/sui-node /usr/local/bin/
mv ~/sui/target/release/sui /usr/local/bin/

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
sudo systemctl restart systemd-journald
sudo systemctl daemon-reload
sudo systemctl enable suid
sudo systemctl start suid
sudo journalctl -fn 100 -u suid
