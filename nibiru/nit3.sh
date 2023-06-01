#!/bin/bash

number=100000000
percentage_min=$(( (number * 10) / 100 ))
percentage_max=$(( (number * 30) / 100 ))

# Open
# nibid tx perp open-position [buy/sell] [pair] [leverage] [quoteAmt / sdk.Dec] [baseAmtLimit / sdk.Dec] [flags]
#command="nibid tx perp open-position buy ubtc:unusd $(shuf -i 10-100 -n 1 | awk '{printf "%.1f", $0/10}') $(shuf -i $percentage_min-$percentage_max -n 1) 0 --from wallet --gas-adjustment 1.4 --gas auto --gas-prices 0.025unibi -y"
command_1="nibid tx perp open-position buy ubtc:unusd $(echo "scale=1; $(shuf -i 10-100 -n 1) / 10" | bc) $(shuf -i $percentage_min-$percentage_max -n 1) 0 --from wallet --gas-adjustment 1.4 --gas auto --gas-prices 0.025unibi -y"
#command_1="nibid tx perp open-position buy ubtc:unusd $(echo "scale=1; $(shuf -i 10-100 -n 1) / 10" | bc) $(shuf -i $percentage_min-$percentage_max -n 1) 0 --from wallet --fees=8500unibi -y"
echo $command_1 && eval $command_1

sleep $(shuf -i 30-200 -n 1)
command_2=$"nibid tx perp open-position buy ueth:unusd $(echo "scale=1; $(shuf -i 10-100 -n 1) / 10" | bc) $(shuf -i $percentage_min-$percentage_max -n 1) 0 --from wallet --gas-adjustment 1.4 --gas auto --gas-prices 0.025unibi -y"
echo $command_2 && eval $command_2

# sleep 30-120 min
sleep $(shuf -i 1800-7200 -n 1)

# Close
command_3=$"nibid tx perp close-position ubtc:unusd  --from wallet --gas-adjustment 1.4 --gas auto --gas-prices 0.025unibi -y"
echo $command_3 && eval $command_3
sleep $(shuf -i 30-200 -n 1)
command_4=$"nibid tx perp close-position ueth:unusd  --from wallet --gas-adjustment 1.4 --gas auto --gas-prices 0.025unibi -y"
echo $command_4 && eval $command_4
sleep $(shuf -i 100-300 -n 1)

# Swap
command_5=$"nibid tx spot swap-assets --token-in=$(shuf -i $percentage_min-$percentage_max -n 1)unusd --token-out-denom=uusdt --from wallet --pool-id=2 --chain-id=$NIBIRU_CHAIN_ID --gas-adjustment 1.4 --gas auto --gas-prices 0.025unibi -y"
echo $command_5 && eval $command_5
sleep $(shuf -i 30-200 -n 1)
command_6=$"nibid tx spot swap-assets --token-in=$(shuf -i $percentage_min-$percentage_max -n 1)uusdt --token-out-denom=unusd --from wallet --pool-id=2 --chain-id=$NIBIRU_CHAIN_ID --gas-adjustment 1.4 --gas auto --gas-prices 0.025unibi -y"
echo $command_6 && eval $command_6
sleep $(shuf -i 30-200 -n 1)

command_7=$"nibid tx spot swap-assets --token-in=$(shuf -i $percentage_min-$percentage_max -n 1)unusd --token-out-denom=unibi --from wallet --pool-id=1 --chain-id=$NIBIRU_CHAIN_ID --gas-adjustment 1.4 --gas auto --gas-prices 0.025unibi -y"
echo $command_7 && eval $command_7
sleep $(shuf -i 30-200 -n 1)
command_8=$"nibid tx spot swap-assets --token-in=$(shuf -i $percentage_min-$percentage_max -n 1)unibi --token-out-denom=unusd --from wallet --pool-id=1 --chain-id=$NIBIRU_CHAIN_ID --gas-adjustment 1.4 --gas auto --gas-prices 0.025unibi -y"
echo $command_8 && eval $command_8
sleep $(shuf -i 30-200 -n 1)

command_9=$"nibid tx spot join-pool --pool-id=1 --tokens-in=$(shuf -i $percentage_min-$percentage_max -n 1)unusd --tokens-in=$(shuf -i $percentage_min-$percentage_max -n 1)unibi --use-all-coins --from wallet --chain-id=$NIBIRU_CHAIN_ID --gas-adjustment 1.4 --gas auto --gas-prices 0.025unibi -y"
echo $command_9 && eval $command_9
sleep $(shuf -i 30-200 -n 1)
command_10=$"nibid tx spot join-pool --pool-id=2 --tokens-in=$(shuf -i $percentage_min-$percentage_max -n 1)unusd --tokens-in=$(shuf -i $percentage_min-$percentage_max -n 1)uusdt --use-all-coins --from wallet --chain-id=$NIBIRU_CHAIN_ID --gas-adjustment 1.4 --gas auto --gas-prices 0.025unibi -y"
echo $command_10 && eval $command_10
