#!/bin/bash
# Set parameters
NODE_NAME="CASCADIA"
NODE_CHAIN_ID="cascadia_6102-1"
NODE_PORT="18"
BINARY_VERSION_TAG="v0.1.2"
CHAIN_DENOM="aCC"
BINARY_NAME="cascadiad"
DIRECTORY="cascadia"
HIDDEN_DIRECTORY=".cascadiad"
# *************************************

# export temp variables
echo 'export NODE_NAME='$NODE_NAME > $HOME/config.sh
echo 'export NODE_CHAIN_ID='$NODE_CHAIN_ID >> $HOME/config.sh
echo 'export NODE_PORT='$NODE_PORT >> $HOME/config.sh
echo 'export BINARY_VERSION_TAG='$BINARY_VERSION_TAG >> $HOME/config.sh
echo 'export CHAIN_DENOM='$CHAIN_DENOM >> $HOME/config.sh
echo 'export BINARY_NAME='$BINARY_NAME >> $HOME/config.sh
echo 'export DIRECTORY='$DIRECTORY >> $HOME/config.sh
echo 'export HIDDEN_DIRECTORY='$HIDDEN_DIRECTORY >> $HOME/config.sh
source $HOME/config.sh

# import code from cosmos/install.sh
source <(curl -s https://raw.githubusercontent.com/NodersUA/Scripts/main/cosmos/install.sh)
