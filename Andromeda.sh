#!/bin/bash

while true
do

# Logo

curl -s https://raw.githubusercontent.com/NodersUA/Scripts/main/logo_1 | bash

# Menu

PS3='Select an action: '
options=(
"Install Node"
"Create wallet"
"Create validator"
"Check node logs"
"Synchronization via StateSync"
"Synchronization via SnapShot"
"UPDATE"
"Delete Node"
"Exit")
select opt in "${options[@]}"
do
case $opt in

"Install Node")
echo "*********************"
echo -e "\e[1m\e[35m		Lets's begin\e[0m"
echo "*********************"
echo -e "\e[1m\e[32m	Enter your MONIKER_ANDROMEDA:\e[0m"
echo "_|-_|-_|-_|-_|-_|-_|"
read MONIKER_ANDROMEDA
echo "_|-_|-_|-_|-_|-_|-_|"
echo export MONIKER_ANDROMEDA=${MONIKER_ANDROMEDA} >> $HOME/.bash_profile
echo export CHAIN_ID_ANDROMEDA=galileo-3 >> $HOME/.bash_profile
echo export PORT_ANDROMEDA=15" >> $HOME/.bash_profile
source ~/.bash_profile

echo -e "\e[1m\e[32m1. Updating packages and dependencies--> \e[0m" && sleep 1
#UPDATE APT
sudo apt update && sudo apt upgrade -y
apt install curl iptables build-essential git wget jq make gcc nano tmux htop nvme-cli pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip libleveldb-dev -y

echo -e "        \e[1m\e[32m2. Installing GO--> \e[0m" && sleep 1
#INSTALL GO
ver="1.20" && \
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz" && \
sudo rm -rf /usr/local/go && \
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz" && \
rm "go$ver.linux-amd64.tar.gz" && \
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> $HOME/.bash_profile && \
source $HOME/.bash_profile && \
go version

echo -e "              \e[1m\e[32m3. Downloading and building binaries--> \e[0m" && sleep 1
#INSTALL
cd $HOME 
git clone https://github.com/andromedaprotocol/andromedad.git
cd andromedad 
git fetch --all 
git checkout galileo-3-v1.1.0-beta1
make install
sudo cp $HOME/go/bin/andromedad /usr/local/bin/andromedad
andromedad version --long | grep -e version -e commit

echo -e "                     \e[1m\e[32m4. Inicializing Node--> \e[0m" && sleep 1
andromedad init $MONIKER_ANDROMEDA --chain-id $CHAIN_ID_ANDROMEDA

echo -e "                     \e[1m\e[32m4. Download Genesis--> \e[0m" && sleep 1

wget -O $HOME/.andromedad/config/genesis.json "https://raw.githubusercontent.com/obajay/nodes-Guides/main/AndromedaProtocol/genesis.json"

sha256sum $HOME/.andromedad/config/genesis.json

echo -e "                     \e[1m\e[32m4. Setup the Ports--> \e[0m" && sleep 1

sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${PORT_ANDROMEDA}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:${PORT_ANDROMEDA}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${PORT_ANDROMEDA}061\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${PORT_ANDROMEDA}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${PORT_ANDROMEDA}660\"%" $HOME/.andromedad/config/config.toml
sed -i.bak -e "s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${PORT_ANDROMEDA}90\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${PORT_ANDROMEDA}91\"%; s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:1${PORT_ANDROMEDA}7\"%" $HOME/.andromedad/config/app.toml
sed -i.bak -e "s%^node = \"tcp://localhost:26657\"%node = \"tcp://localhost:${PORT_ANDROMEDA}657\"%" $HOME/.andromedad/config/client.toml
external_address=$(wget -qO- eth0.me)
sed -i.bak -e "s/^external_address *=.*/external_address = \"$external_address:${PORT_ANDROMEDA}656\"/" $HOME/.andromedad/config/config.toml


echo -e "                     \e[1m\e[32m4. Setup Config--> \e[0m" && sleep 1

andromedad config chain-id galileo-3
andromedad config keyring-backend os
andromedad config node tcp://localhost:${PORT_ANDROMEDA}657
sed -i.bak -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.0025uandr\"/;" ~/.andromedad/config/app.toml
peers=""
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$peers\"/" $HOME/.andromedad/config/config.toml
seeds="3a445bfdbe2d0c8ee82461633aa3af31bc2b4dc0@prod-pnet-seed-node.lavanet.xyz:26656,e593c7a9ca61f5616119d6beb5bd8ef5dd28d62d@prod-pnet-seed-node2.lavanet.xyz:26656"
sed -i.bak -e "s/^seeds =.*/seeds = \"$seeds\"/" $HOME/.andromedad/config/config.toml
sed -i -e "s/^filter_peers *=.*/filter_peers = \"true\"/" $HOME/.andromedad/config/config.toml
sed -i -e "s/^timeout_commit *=.*/timeout_commit = \"60s\"/" $HOME/.andromedad/config/config.toml
sed -i -e "s/^timeout_propose *=.*/timeout_propose = \"60s\"/" $HOME/.andromedad/config/config.toml
sed -i -e "s/^create_empty_blocks_interval *=.*/create_empty_blocks_interval = \"60s\"/" $HOME/.andromedad/config/config.toml
sed -i 's/create_empty_blocks = .*/create_empty_blocks = true/g' ~/.andromedad/config/config.toml
sed -i 's/timeout_broadcast_tx_commit = ".*s"/timeout_broadcast_tx_commit = "601s"/g' ~/.andromedad/config/config.toml

pruning="custom"
pruning_keep_recent="100"
pruning_keep_every="0"
pruning_interval="10"
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/.andromedad/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/.andromedad/config/app.toml
sed -i -e "s/^pruning-keep-every *=.*/pruning-keep-every = \"$pruning_keep_every\"/" $HOME/.andromedad/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/.andromedad/config/app.toml

echo -e "                     \e[1m\e[32m4. Cosmovisor--> \e[0m" && sleep 1

go install cosmossdk.io/tools/cosmovisor/cmd/cosmovisor@latest
mkdir -p ~/.andromedad/cosmovisor
mkdir -p ~/.andromedad/cosmovisor/genesis
mkdir -p ~/.andromedad/cosmovisor/genesis/bin
mkdir -p ~/.andromedad/cosmovisor/upgrades
cp `which andromedad` ~/.andromedad/cosmovisor/genesis/bin/andromedad

echo -e "                     \e[1m\e[32m4. Service File--> \e[0m" && sleep 1

sudo tee /etc/systemd/system/andromedad.service > /dev/null <<EOF
[Unit]
Description=andromeda daemon
After=network-online.target

[Service]
User=$USER
ExecStart=$(which cosmovisor) run start --x-crisis-skip-assert-invariants
Restart=always
RestartSec=3
LimitNOFILE=infinity

Environment="DAEMON_NAME=andromedad"
Environment="DAEMON_HOME=${HOME}/.andromedad"
Environment="DAEMON_RESTART_AFTER_UPGRADE=true"
Environment="DAEMON_ALLOW_DOWNLOAD_BINARIES=false"

[Install]
WantedBy=multi-user.target
EOF

# start the node
sudo systemctl daemon-reload
sudo systemctl enable nibid
sudo systemctl restart nibid

echo '=============== SETUP FINISHED ==================='
echo -e 'Congratulations:        \e[1m\e[32mSUCCESSFUL NODE INSTALLATION\e[0m'
echo -e 'To check logs:        \e[1m\e[33mjournalctl -u andromedad -f -o cat\e[0m'
echo -e "To check sync status: \e[1m\e[35mandromedad status 2>&1 | jq "{catching_up: .SyncInfo.catching_up}"\e[0m"

break
;;
"Create wallet")
andromedad keys add wallet
echo "_|-_|-_|-_|-_|-_|-_|"
echo -e "      \e[1m\e[35m WALLET_ANDROMEDA:\e[0m"
echo "_|-_|-_|-_|-_|-_|-_|"
read WALLET_ANDROMEDA
echo export WALLET_ANDROMEDA=${WALLET_ANDROMEDA} >> $HOME/.bash_profile
source ~/.bash_profile

echo -e "      \e[1m\e[32m!!!!!!!!!SAVE!!!!!!!!!!!!!!!!SAVE YOUR MNEMONIC PHRASE!!!!!!!!!SAVE!!!!!!!!!!!!!!!!\e[0m" && sleep 1

break
;;
"Create validator")
andromedad tx staking create-validator \
--amount 1000000uandr \
--from=wallet \
--commission-rate "0.15" \
--commission-max-rate "0.20" \
--commission-max-change-rate "0.1" \
--min-self-delegation "1" \
--pubkey=$(andromedad tendermint show-validator) \
--moniker=$MONIKER_ANDROMEDA \
--chain-id=$CHAIN_ID_ANDROMEDA \
--fees=1000uandr \
-y

break
;;
"Synchronization via StateSync")
echo -e "      \e[1m\e[32m SOOOON\e[0m"

break
;;
"UPDATE")
echo -e "      \e[1m\e[32m Update soon\e[0m"

cd $HOME/andromedad
git pull
git checkout 
make build
$HOME/andromedad/build/andromedad version --long | grep -e version -e commit
systemctl stop andromedad
mv $HOME/andromedad/build/andromedad $(which andromedad)
andromedad version --long | grep -e version -e commit
systemctl restart andromedad && journalctl -u andromedad -f -o cat

break
;;
"Check node logs")
journalctl -u andromedad -f -o cat

break
;;
"Synchronization via SnapShot")
echo -e "      \e[1m\e[32m SnapShot\e[0m"

snapshot_interval=1000
sed -i.bak -e "s/^snapshot-interval *=.*/snapshot-interval = \"$snapshot_interval\"/" ~/.andromedad/config/app.toml

# install lz4
apt update
apt install snapd -y
snap install lz4

sudo systemctl stop andromedad
cp $HOME/.andromedad/data/priv_validator_state.json $HOME/.andromedad/priv_validator_state.json.backup
rm -rf $HOME/.andromedad/data
curl -o - -L http://andromedad.snapshot.stavr.tech:1021/andromedad/andromedad-snap.tar.lz4 | lz4 -c -d - | tar -x -C $HOME/.andromedad --strip-components 2
curl -o - -L http://andromedad.wasm.stavr.tech:1002/wasm-andromedad.tar.lz4 | lz4 -c -d - | tar -x -C $HOME/.andromedad --strip-components 2
mv $HOME/.andromedad/priv_validator_state.json.backup $HOME/.andromedad/data/priv_validator_state.json
wget -O $HOME/.andromedad/config/addrbook.json "https://raw.githubusercontent.com/obajay/nodes-Guides/main/AndromedaProtocol/addrbook.json"
sudo systemctl restart andromedad && journalctl -u andromedad -f -o cat

break
;;
"Delete Node")
sudo systemctl stop andromedad && \
sudo systemctl disable andromedad && \
rm /etc/systemd/system/andromedad.service && \
sudo systemctl daemon-reload && \
cd $HOME && \
rm -rf andromedad && \
rm -rf .andromedad && \
rm -rf $(which andromedad)

break
;;
"Exit")
exit
break
esac
done
done
