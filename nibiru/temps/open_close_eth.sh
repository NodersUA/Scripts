#!/bin/bash

sleep $(shuf -i 0-3600 -n 1)
nibid tx perp open-position buy ueth:unusd $(echo "scale=1; $(shuf -i 10-100 -n 1) / 10" | bc) $(shuf -i 10000000-30000000 -n 1) 0 --from wallet --gas-adjustment 1.4 --gas auto --gas-prices 0.025unibi -y

sleep $(shuf -i 1800-3600 -n 1)
nibid tx perp close-position ueth:unusd  --from wallet --gas-adjustment 1.4 --gas auto --gas-prices 0.025unibi -y
