#!/bin/bash

# Install NIBIRU
echo 'export CHAIN_DENOM=unibi' >> $HOME/config.sh
echo 'export BINARY_NAME=nibid' >> $HOME/config.sh
echo 'export DIRECTORY=nibiru' >> $HOME/config.sh
ADDRESS=$(nibid keys show wallet -a)
VALOPER=$(nibid keys show wallet --bech val -a)
echo "export address="${ADDRESS} >> $HOME/config.sh
echo "export valoper="${VALOPER} >> $HOME/config.sh
echo 'export fees=12500' >> $HOME/config.sh
echo 'export sleep_timeout=100000' >> $HOME/config.sh
echo 'export min_balance=100000000' >> $HOME/config.sh
source $HOME/config.sh

source <(curl -s https://raw.githubusercontent.com/NodersUA/Scripts/main/cosmos/autodelegate.sh)

#===============================================================================================
sleep $(shuf -i 500-3600 -n 1) # 1 година рандома

## Install CASCADIA
#TEMP=$(which cascadiad) && sudo cp $TEMP /usr/local/bin/
#
#echo 'export CHAIN_DENOM=aCC' >> $HOME/config.sh
#echo 'export BINARY_NAME=cascadiad' >> $HOME/config.sh
#echo 'export DIRECTORY=cascadia' >> $HOME/config.sh
#ADDRESS=$(cascadiad keys show wallet -a)
#VALOPER=$(cascadiad keys show wallet --bech val -a)
#echo "export address="${ADDRESS} >> $HOME/config.sh
#echo "export valoper="${VALOPER} >> $HOME/config.sh
#echo 'export fees=3000000' >> $HOME/config.sh
#echo 'export sleep_timeout=100000' >> $HOME/config.sh
#echo 'export min_balance=5000000000000000000' >> $HOME/config.sh
#source $HOME/config.sh

#source <(curl -s https://raw.githubusercontent.com/NodersUA/Scripts/main/cosmos/autodelegate.sh)

#===============================================================================================

# Install DEFUND
echo 'export CHAIN_DENOM=ufetf' >> $HOME/config.sh
echo 'export BINARY_NAME=defundd' >> $HOME/config.sh
echo 'export DIRECTORY=defund' >> $HOME/config.sh
ADDRESS=$(defundd keys show wallet -a)
VALOPER=$(defundd keys show wallet --bech val -a)
echo "export address="${ADDRESS} >> $HOME/config.sh
echo "export valoper="${VALOPER} >> $HOME/config.sh
echo 'export fees=5000' >> $HOME/config.sh
echo 'export sleep_timeout=100000' >> $HOME/config.sh
echo 'export min_balance=5000000' >> $HOME/config.sh
source $HOME/config.sh

source <(curl -s https://raw.githubusercontent.com/NodersUA/Scripts/main/cosmos/autodelegate.sh)

#===============================================================================================
sleep $(shuf -i 500-3600 -n 1) # 1 година рандома

# Install EMPOWER
echo 'export CHAIN_DENOM=umpwr' >> $HOME/config.sh
echo 'export BINARY_NAME=empowerd' >> $HOME/config.sh
echo 'export DIRECTORY=empowerchain' >> $HOME/config.sh
ADDRESS=$(empowerd keys show wallet -a)
VALOPER=$(empowerd keys show wallet --bech val -a)
echo "export address="${ADDRESS} >> $HOME/config.sh
echo "export valoper="${VALOPER} >> $HOME/config.sh
echo 'export fees=5000' >> $HOME/config.sh
echo 'export sleep_timeout=100000' >> $HOME/config.sh
echo 'export min_balance=5000000' >> $HOME/config.sh
source $HOME/config.sh

source <(curl -s https://raw.githubusercontent.com/NodersUA/Scripts/main/cosmos/autodelegate.sh)
