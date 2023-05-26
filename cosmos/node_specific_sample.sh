# Set parameters
NODE_NAME="CASCADIA"
NODE_CHAIN_ID="cascadia_6102-1"
NODE_PORT="18"
BINARY_VERSION_TAG="v0.1.2"
CHAIN_DENOM="aCC"
# *************************************

# export temp variables
echo 'export NODE_NAME='$NODE_NAME >> $HOME/.bash_profile
echo 'export NODE_CHAIN_ID='$NODE_CHAIN_ID >> $HOME/.bash_profile
echo 'export NODE_PORT='$NODE_PORT >> $HOME/.bash_profile
echo 'export BINARY_VERSION_TAG='$BINARY_VERSION_TAG >> $HOME/.bash_profile
echo 'export CHAIN_DENOM='$CHAIN_DENOM >> $HOME/.bash_profile
source $HOME/.bash_profile

# import code from cosmos/install.sh
source <(curl -s https://raw.githubusercontent.com/NodersUA/Scripts/main/cosmos/install.sh)
