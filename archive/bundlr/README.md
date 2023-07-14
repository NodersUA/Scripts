# Run script
```bash
source <(curl -s https://raw.githubusercontent.com/NodersUA/Scripts/main/bundlr/bundlr)
```
You can claim Testnet tokens [here](https://bundlr.network/faucet), you will need a valid twitter account and the Arweave wallet address created earlier.
```bash
# Check ballance
npx @bundlr-network/testnet-cli@latest balance $BUNDLR_ADDRESS
```
```bash
# Register Validator and Stake
npx @bundlr-network/testnet-cli@latest join $GW_CONTRACT -w $HOME/bundlr/wallet.json -u http://$(wget -qO- eth0.me):$BUNDLER_PORT -s <stake-tokens>
```
