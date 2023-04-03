```bash
MONIKER=
```

```bash
# Install
source <(curl -s https://raw.githubusercontent.com/NodersUA/Scripts/main/nibiru/nibiru.sh)
```

```bash
# Create wallet
nibid keys add wallet

NIBIRU_ADDRESS=

echo "export NIBIRU_ADDRESS="${NIBIRU_ADDRESS}"" >> $HOME/.bash_profile
source $HOME/.bash_profile
```

```bash
nibid tx staking create-validator \
--amount 1000000unibi \
--from=wallet \
--commission-rate "0.05" \
--commission-max-rate "0.20" \
--commission-max-change-rate "0.1" \
--min-self-delegation "1" \
--pubkey=$(nibid tendermint show-validator) \
--moniker=$MONIKER \
--chain-id=$NIBIRU_CHAIN_ID \
--fees=5000unibi \
-y
```
