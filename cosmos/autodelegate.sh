#!/bin/bash

if ! dpkg -s bc &> /dev/null; then
sudo apt update && apt upgrade -y
apt install bc -y
fi

# make sure scripts is in path. If not then make dir
mkdir -p "~/scripts"

#===========================================================================

# write nibiru_autorestart.sh to scripts/
tee ~/scripts/ad_${DIRECTORY}.sh > /dev/null <<EOF
#!/bin/bash

GREEN="\e[32m"
ENDCOLOR="\e[0m"

next=false
def_sleep_timeout=$sleep_timeout
sleep_timeout=$sleep_timeout
min_balance=$min_balance
address=$address
valoper=$valoper

get_balance() { ${BINARY_NAME} q bank balances \${address} --output=json | jq -r '.balances[] | select(.denom == "${CHAIN_DENOM}") | .amount' | tr -d '"' ;}

get_timeout() {
  if [ "\$status" = "BOND_STATUS_BONDED" ]; then
    per_sec=\$((delegate / sleep_timeout))
    procent=\$(echo "scale=10; \$per_sec / \$voting_power" | bc)
    sleep_timeout=\$(echo "scale=10; $gas * 3 * 7 / (\$per_sec * \$procent)" | bc)
    sleep_timeout=\$(printf "%.0f" "\$sleep_timeout")
    [ "\$sleep_timeout" -lt 60 ] && sleep_timeout=60
  else
    sleep_timeout=\$def_sleep_timeout
  fi
}

execute_with_sequence_check() {
  cmd=\$1
  sequence=\$(${BINARY_NAME} query account \${address} | grep -oP '(?<=sequence: ")[^"]+' | awk '{print \$1}')
  if [ "$BINARY_NAME" = "sided" ]; then
    new_cmd="\$cmd --keyring-backend test --sequence=\$sequence -y"
  else
    new_cmd="\$cmd --sequence=\$sequence -y"
  fi
  echo \$new_cmd
  echo "\$(eval \${new_cmd})"
}

sl=\$(shuf -i 0-10000 -n 1)
echo "sleep \$sl sec..."
sleep \$sl

while true; do

status=\$(${BINARY_NAME} q staking validator \${valoper} --output=json | jq -r '.status')

echo -e "\${GREEN}>>> Date: [ \$(date) ]\${ENDCOLOR}"

voting_power=\$(${BINARY_NAME} q staking validator \${valoper} | grep -oP '(?<=tokens: ")[^"]+') && sleep 1
start_balance=\$(get_balance) && sleep 1

if [ "\$status" == "BOND_STATUS_BONDED" ]; then
echo -e "\${GREEN}>>> Withdraw rewards and commission \${ENDCOLOR}"
# echo "\$(${BINARY_NAME} tx distribution withdraw-rewards \${valoper} --from wallet --gas $gas --gas-adjustment=1.4 --gas-prices=${MINIMUM_GAS_PRICES} --commission -y)"
execute_with_sequence_check "${BINARY_NAME} tx distribution withdraw-rewards \${valoper} --from wallet --gas $gas --gas-adjustment=1.4 --gas-prices=${MINIMUM_GAS_PRICES} --commission -y"
sleep 10
echo -e "\${GREEN}>>> Withdraw all rewards \${ENDCOLOR}"
#echo -e "\$(${BINARY_NAME} tx distribution withdraw-all-rewards --from wallet --gas $gas --gas-adjustment=1.4 --gas-prices=${MINIMUM_GAS_PRICES} -y)"
execute_with_sequence_check "${BINARY_NAME} tx distribution withdraw-all-rewards --from wallet --gas $gas --gas-adjustment=1.4 --gas-prices=${MINIMUM_GAS_PRICES} -y"
fi

sleep 10
balance=\$(get_balance) && sleep 1
delegate=\$(echo "\$balance - \$min_balance" | bc)
if [[ \$delegate > 0 && -n  "\$delegate" ]]; then
echo -e "\${GREEN}>>> Delegate \${delegate}${CHAIN_DENOM} \${ENDCOLOR}"
execute_with_sequence_check "${BINARY_NAME} tx staking delegate \${valoper} \${delegate}${CHAIN_DENOM} --from wallet --gas $gas --gas-adjustment=1.4 --gas-prices=${MINIMUM_GAS_PRICES}"
else
echo -e "\${GREEN}>>> Balance [ \${balance} ] < min_balance [ \${min_balance} ] \${ENDCOLOR}"
fi

[ -n "\$next" ] && \$(get_timeout)
next=true

echo -e "\${GREEN}>>> Sleep \${sleep_timeout} sec \${ENDCOLOR}"
sleep \$sleep_timeout

done

EOF

chmod +x ~/scripts/ad_${DIRECTORY}.sh

#===========================================================================

# Create ad_${DIRECTORY} service file (One command)
sudo tee /etc/systemd/system/ad_${DIRECTORY}.service > /dev/null <<EOF
[Unit]
Description=ad_${DIRECTORY} service
After=network.target

[Service]
User=$USER
ExecStart=$HOME/scripts/ad_${DIRECTORY}.sh
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Start Diskord service file
systemctl daemon-reload
systemctl enable ad_${DIRECTORY}
systemctl restart ad_${DIRECTORY}
