#!/bin/bash

sed -i -e "s/^indexer *=.*/indexer = \"kv\"/" ~/.nibid/config/config.toml
systemctl restart nibiid
sleep 60

cd && git clone https://github.com/NibiruChain/cw-nibiru
txhash=$(nibid tx wasm store $HOME/cw-nibiru/artifacts-cw-plus/cw20_base.wasm --from wallet \
--gas-adjustment 1.2 --gas auto --fees 80000unibi -y -o json | jq -r '.txhash')
echo "$txhash"

sleep 5
code_id=""
while [ -z "$code_id" ]; do
    code_id=$(nibid q tx $txhash -o json | jq -r '.logs[].events[].attributes[] | select(.key=="code_id").value')
    echo "code_id: $code_id"
    sleep 5
done
if [ -z "$NIBIRU_MONIKER" ]; then 
    NIBIRU_MONIKER=$MONIKER
    echo 'export NIBIRU_MONIKER='$NIBIRU_MONIKER >> $HOME/.bash_profile
    source $HOME/.bash_profile
fi
INIT="{\"name\":\"$NIBIRU_MONIKER\",\"symbol\":\"$(echo $NIBIRU_MONIKER | cut -c1-4)\",\"decimals\":6,\"initial_balances\":[{\"address\":\"$NIBIRU_ADDRESS\",\"amount\":\"2000000\"}],\"mint\":{\"minter\":\"$NIBIRU_ADDRESS\"},\"marketing\":{}}" && \
nibid tx wasm instantiate $code_id "$INIT" --from wallet --label "$NIBIRU_MONIKER cw20_base" --gas-adjustment 1.2 --gas 8000000 --fees 200000unibi --no-admin -y

nibid keys add transfer_wallet
transfer_wallet=$(nibid keys show transfer_wallet -a) && \
BALANCE_QUERY="{\"balance\": {\"address\": \"$NIBIRU_ADDRESS\"}}" && \
TRANSFER="{\"transfer\":{\"recipient\":\"$transfer_wallet\",\"amount\":\"50\"}}" && \
CONTRACT="null"
while [ "$CONTRACT" = "null" ]; do CONTRACT=$(nibid query wasm list-contract-by-code $code_id --output json | jq -r '.contracts[-1]'); sleep 5; done
nibid tx wasm execute $CONTRACT $TRANSFER --gas-adjustment 1.2 --gas 8000000 --fees 200000unibi --from wallet --chain-id $NIBIRU_CHAIN_ID -y && sleep 7
nibid query wasm contract-state smart $CONTRACT "$BALANCE_QUERY" --output json

sed -i -e "s/^indexer *=.*/indexer = \"null\"/" ~/.nibid/config/config.toml
systemctl restart nibiid
