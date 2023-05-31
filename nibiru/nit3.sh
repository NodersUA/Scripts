#!/bin/bash

number=100000000
percentage_min=$(( (number * 10) / 100 ))
percentage_max=$(( (number * 30) / 100 ))

# Open
# nibid tx perp open-position [buy/sell] [pair] [leverage] [quoteAmt / sdk.Dec] [baseAmtLimit / sdk.Dec] [flags]
#command=$"nibid tx perp open-position buy ubtc:unusd $(shuf -i 10-100 -n 1 | awk '{printf "%.1f", $0/10}') $(shuf -i $percentage_min-$percentage_max -n 1)000 0 --from wallet --gas-adjustment 1.4 --gas auto --gas-prices 0.025unibi -y"
command="nibid tx perp open-position buy ubtc:unusd $(shuf -i 10-100 -n 1 | awk '{printf "%.1f", $0/10}') $(shuf -i $percentage_min-$percentage_max -n 1)000 0 --from wallet --gas-adjustment 1.4 --gas auto --gas-prices 0.025unibi -y"
echo $command && eval $command

sleep $(shuf -i 30-200 -n 1)
command=$"nibid tx perp open-position buy ueth:unusd $(shuf -i 10-100 -n 1 | awk '{printf "%.1f", $0/10}') $(shuf -i $percentage_min-$percentage_max -n 1)000 0 --from wallet --gas-adjustment 1.4 --gas auto --gas-prices 0.025unibi -y"
echo $command && eval $command

# sleep 30-120 min
sleep $(shuf -i 1800-7200 -n 1)

# Close
nibid tx perp close-position ubtc:unusd  --from wallet --gas-adjustment 1.4 --gas auto --gas-prices 0.025unibi -y
sleep $(shuf -i 30-200 -n 1)
nibid tx perp close-position ueth:unusd  --from wallet --gas-adjustment 1.4 --gas auto --gas-prices 0.025unibi -y

# Swap
nibid tx spot swap-assets --token-in=$(shuf -i $percentage_min-$percentage_max -n 1)000unusd --token-out-denom=uusdt --from wallet --pool-id=2 --chain-id=$NIBIRU_CHAIN_ID --gas-adjustment 1.4 --gas auto --gas-prices 0.025unibi -y
sleep $(shuf -i 30-200 -n 1)
nibid tx spot swap-assets --token-in=$(shuf -i $percentage_min-$percentage_max -n 1)000uusdt --token-out-denom=unusd --from wallet --pool-id=2 --chain-id=$NIBIRU_CHAIN_ID --gas-adjustment 1.4 --gas auto --gas-prices 0.025unibi -y
sleep $(shuf -i 30-200 -n 1)

nibid tx spot swap-assets --token-in=$(shuf -i $percentage_min-$percentage_max -n 1)000unusd --token-out-denom=unibi --from wallet --pool-id=1 --chain-id=$NIBIRU_CHAIN_ID --gas-adjustment 1.4 --gas auto --gas-prices 0.025unibi -y
sleep $(shuf -i 30-200 -n 1)
nibid tx spot swap-assets --token-in=$(shuf -i $percentage_min-$percentage_max -n 1)000unibi --token-out-denom=unusd --from wallet --pool-id=1 --chain-id=$NIBIRU_CHAIN_ID --gas-adjustment 1.4 --gas auto --gas-prices 0.025unibi -y
