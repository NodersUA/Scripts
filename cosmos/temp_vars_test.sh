#!/bin/bash

cd $HOME

# Create a configuration file
echo 'NODE_NAME="CASCADIA"' > config.sh
echo 'NODE_CHAIN_ID="cascadia_6102-1"' >> config.sh
echo 'NODE_PORT="18"' >> config.sh
echo 'BINARY_VERSION_TAG="v0.1.2"' >> config.sh
echo 'CHAIN_DENOM="aCC"' >> config.sh

# Source the configuration file in your script
source config.sh

# Call the script
./your_script.sh
