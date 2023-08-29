#!/bin/bash

if [ -z "$MONIKER" ]; then
  echo "*********************"
  echo -e "\e[1m\e[34m		Lets's begin\e[0m"
  echo "*********************"
  echo -e "\e[1m\e[32m	Enter your MONIKER:\e[0m"
  echo "*********************"
  read MONIKER
  echo 'export MONIKER='$MONIKER >> $HOME/.bash_profile
  source ~/.bash_profile
fi

echo "*****************************"
echo -e "\e[1m\e[32m Node moniker:       $MONIKER \e[0m"
echo -e "\e[1m\e[32m Chain id:           $NODE_CHAIN_ID \e[0m"
echo -e "\e[1m\e[32m Chain demon:        $CHAIN_DENOM \e[0m"
echo -e "\e[1m\e[32m Binary version tag: $BINARY_VERSION_TAG \e[0m"
echo -e "\e[1m\e[32m Binary name:        $BINARY_NAME \e[0m"
echo -e "\e[1m\e[32m Directory:          $DIRECTORY \e[0m"
echo -e "\e[1m\e[32m Hidden directory:   $HIDDEN_DIRECTORY \e[0m"
echo "*****************************"
sleep 1

PS3='Select an action: '
options=("Create a new wallet" "Recover an old wallet" "Exit")
select opt in "${options[@]}"
do
  case $opt in
    "Create a new wallet")
      command="$BINARY_NAME keys add wallet && echo -e '      \e[1m\e[31m!!!!!!!!!SAVE!!!!!!!!!!!!!!!!SAVE YOUR MNEMONIC PHRASE!!!!!!!!!SAVE!!!!!!!!!!!!!!!!\e[0m'"
      break
      ;;
    "Recover an old wallet")
      command="$BINARY_NAME keys add wallet --recover"
      break
      ;;
    "Exit")
      exit
      ;;
    *) echo "Invalid option. Please try again.";;
  esac
done

#==================================================================================================

echo -e "\e[1m\e[32m [[\\\\\***** Updating packages and dependencies *****/////]] \e[0m" && sleep 1
#UPDATE APT
sudo apt update && apt upgrade -y
apt install bc curl iptables build-essential git wget jq make gcc nano tmux htop nvme-cli pkg-config libssl-dev libleveldb-dev tar clang bsdmainutils ncdu unzip libleveldb-dev -y

#==================================================================================================

echo -e "\e[1m\e[32m [[\\\\\***** Installing GO *****/////]] \e[0m" && sleep 1
#INSTALL GO
if [ "$(go version)" != "go version go1.20.5 linux/amd64" ]; then \
ver="1.20.5" && \
wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz" && \
sudo rm -rf /usr/local/go && \
sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz" && \
rm "go$ver.linux-amd64.tar.gz" && \
echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> $HOME/.bash_profile && \
source $HOME/.bash_profile ; \
fi
go version

#==================================================================================================

echo -e "\e[1m\e[32m [[\\\\\***** Downloading and building binaries *****/////]] \e[0m" && sleep 1
#INSTALL
cd $HOME
git clone $NODE_URL && cd $DIRECTORY
git fetch --all
git checkout $BINARY_VERSION_TAG
if [ $NODE_NAME=="EMPOWER" ]; then cd chain; fi
make install
TEMP=$(which $BINARY_NAME)
sudo cp $TEMP /usr/local/bin/ && cd $HOME
$BINARY_NAME version --long | grep -e version -e commit

$BINARY_NAME init $MONIKER --chain-id $NODE_CHAIN_ID

wget -O $HOME/$HIDDEN_DIRECTORY/config/genesis.json $GENESIS_URL

#==================================================================================================

echo -e "\e[1m\e[32m [[\\\\\***** Set the ports *****/////]] \e[0m" && sleep 1
external_address=$(wget -qO- eth0.me)
# config.toml
sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:${NODE_PORT}658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://${external_address}:${NODE_PORT}657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:${NODE_PORT}061\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:${NODE_PORT}656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":${NODE_PORT}660\"%" $HOME/$HIDDEN_DIRECTORY/config/config.toml
sed -i.bak -e "s/^external_address *=.*/external_address = \"$external_address:${NODE_PORT}656\"/" $HOME/$HIDDEN_DIRECTORY/config/config.toml
# app.toml
sed -i.bak -e "s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:${NODE_PORT}90\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:${NODE_PORT}91\"%; s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:1${NODE_PORT}7\"%" $HOME/$HIDDEN_DIRECTORY/config/app.toml
sed -i.bak -e "s%^address = \"localhost:9090\"%address = \"localhost:${NODE_PORT}90\"%; s%^address = \"localhost:9091\"%address = \"localhost:${NODE_PORT}91\"%; s%^address = \"tcp://localhost:1317\"%address = \"tcp://localhost:1${NODE_PORT}7\"%" $HOME/$HIDDEN_DIRECTORY/config/app.toml
# client.toml
sed -i.bak -e "s%^node *=.*\"%node = \"tcp://${external_address}:${NODE_PORT}657\"%" $HOME/$HIDDEN_DIRECTORY/config/client.toml

ufw allow ${NODE_PORT}657

#==================================================================================================

echo -e "\e[1m\e[32m [[\\\\\***** Setup config *****/////]] \e[0m" && sleep 1
# correct config (so we can no longer use the chain-id flag for every CLI command in client.toml)
$BINARY_NAME config chain-id $NODE_CHAIN_ID

# adjust if necessary keyring-backend в client.toml 
$BINARY_NAME config keyring-backend test

$BINARY_NAME config node tcp://${external_address}:${NODE_PORT}657

# Set the minimum price for gas
sed -i.bak -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"$MINIMUM_GAS_PRICES\"/;" ~/$HIDDEN_DIRECTORY/config/app.toml

# Add seeds/peers в config.toml
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" $HOME/$HIDDEN_DIRECTORY/config/config.toml
sed -i.bak -e "s/^seeds =.*/seeds = \"$SEEDS\"/" $HOME/$HIDDEN_DIRECTORY/config/config.toml

# Set up filter for "bad" peers
sed -i -e "s/^filter_peers *=.*/filter_peers = \"true\"/" $HOME/$HIDDEN_DIRECTORY/config/config.toml

# Set up pruning
sed -i -e "s/^pruning *=.*/pruning = \"$pruning\"/" $HOME/$HIDDEN_DIRECTORY/config/app.toml
sed -i -e "s/^pruning-keep-recent *=.*/pruning-keep-recent = \"$pruning_keep_recent\"/" $HOME/$HIDDEN_DIRECTORY/config/app.toml
sed -i -e "s/^pruning-interval *=.*/pruning-interval = \"$pruning_interval\"/" $HOME/$HIDDEN_DIRECTORY/config/app.toml
sed -i -e "s/^snapshot-interval *=.*/snapshot-interval = \"$snapshot_interval\"/" $HOME/$HIDDEN_DIRECTORY/config/app.toml

sed -i -e "s/^indexer *=.*/indexer = \"$indexer\"/" $HOME/$HIDDEN_DIRECTORY/config/config.toml

#==================================================================================================

echo -e "\e[1m\e[32m [[\\\\\***** Service File *****/////]] \e[0m" && sleep 1
# Create service file (One command)
sudo tee /etc/systemd/system/$BINARY_NAME.service > /dev/null <<EOF
[Unit]
Description=$NODE_NAME Node
After=network.target
 
[Service]
Type=simple
User=$USER
WorkingDirectory=$HOME/go/bin
ExecStart=/root/go/bin/$BINARY_NAME start
Restart=on-failure
StartLimitInterval=0
RestartSec=3
LimitNOFILE=65535
LimitMEMLOCK=209715200
 
[Install]
WantedBy=multi-user.target
EOF

# Start the node
systemctl daemon-reload
systemctl enable $BINARY_NAME
systemctl restart $BINARY_NAME

#==================================================================================================

# set up cosmos_autorestart (disabled)
source <(curl -s https://raw.githubusercontent.com/NodersUA/Scripts/main/cosmos/autorestart.sh)

#==================================================================================================

echo '=============== SETUP FINISHED ==================='
echo -e 'Congratulations:        \e[1m\e[32mSUCCESSFUL NODE INSTALLATION\e[0m'
echo -e 'To check logs:        \e[1m\e[33mjournalctl -u $BINARY_NAME -f -o cat\e[0m'
echo -e "To check sync status: \e[1m\e[35mcurl localhost:${NODE_PORT}657/status\e[0m"

#==================================================================================================

echo -e "\e[1m\e[32m [[\\\\\***** Wallet *****/////]] \e[0m" && sleep 1

# Execute the saved command
eval "$command"

ADDRESS=$($BINARY_NAME keys show wallet -a)
VALOPER=$($BINARY_NAME keys show wallet --bech val -a)
echo "export ${NODE_NAME}_ADDRESS="${ADDRESS} >> $HOME/.bash_profile
echo "export ${NODE_NAME}_VALOPER="${VALOPER} >> $HOME/.bash_profile
echo "export ${NODE_NAME}_CHAIN_ID="${NODE_CHAIN_ID} >> $HOME/.bash_profile
source $HOME/.bash_profile
