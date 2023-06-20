#!/bin/bash

if ! dpkg -s bc &> /dev/null; then
sudo apt update && apt upgrade -y
apt install bc -y
fi

# make sure scripts is in path. If not then make dir
mkdir -p "$HOME/scripts"

#===========================================================================

# write nibiru_autorestart.sh to scripts/
tee $HOME/scripts/${DIRECTORY}_autodelegate.sh > /dev/null <<EOF
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
  status=\$(${BINARY_NAME} q staking validator \${valoper} --output=json | jq -r '.status')
  if [ "\$status" == "BOND_STATUS_BONDED" ]; then
    per_sec=\$((delegate / sleep_timeout))
    procent=\$(echo "scale=10; \$per_sec / \$voting_power" | bc)
    sleep_timeout=\$(echo "scale=10; $fees * 2 / (\$per_sec * \$procent)" | bc)
  else
    sleep_timeout=\$def_sleep_timeout
  fi
}

execute_with_sequence_check() {
  cmd=\$1
  sequence=\$(${BINARY_NAME} query account \${address} | grep -oP '(?<=sequence: ")[^"]+' | awk '{print \$1}')
  new_cmd="\$cmd --sequence=\$sequence -y"
  echo \$new_cmd
  echo "\$(eval \${new_cmd})"
}

while true; do

echo -e "\${GREEN}>>> Date: [ \$(date) ]\${ENDCOLOR}"

voting_power=\$(${BINARY_NAME} q staking validator \${valoper} | grep -oP '(?<=tokens: ")[^"]+') && sleep 1
start_balance=\$(get_balance) && sleep 1

echo -e "\${GREEN}>>> Withdraw all rewards \${ENDCOLOR}"
echo "\$(${BINARY_NAME} tx distribution withdraw-rewards \${valoper} --from wallet --fees ${fees}${CHAIN_DENOM} --gas=500000 --commission -y)"

sleep 3
balance=\$(get_balance) && sleep 1
delegate=\$((balance - min_balance))
if [[ \$delegate > 0 && -n  "\$delegate" ]]; then
echo -e "\${GREEN}>>> Delegate \${delegate}${CHAIN_DENOM} \${ENDCOLOR}"
execute_with_sequence_check "${BINARY_NAME} tx staking delegate \${valoper} \${delegate}${CHAIN_DENOM} --from wallet --fees ${fees}${CHAIN_DENOM} --gas=500000"
else
echo -e "\${GREEN}>>> Balance [ \${balance} ] < min_balance [ \${min_balance} ] \${ENDCOLOR}"
fi

[ -n "\$next" ] && \$(get_timeout)
next=true

echo -e "\${GREEN}>>> Sleep \${sleep_timeout} sec \${ENDCOLOR}"
sleep \$sleep_timeout

done

EOF

chmod +x $HOME/scripts/${DIRECTORY}_autodelegate.sh

#===========================================================================

# Create ${DIRECTORY}_autodelegate service file (One command)
sudo tee /etc/systemd/system/${DIRECTORY}_autodelegate.service > /dev/null <<EOF
[Unit]
Description=${DIRECTORY}_autodelegate service
After=network.target

[Service]
User=$USER
ExecStart=$HOME/scripts/${DIRECTORY}_autodelegate.sh
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Start Diskord service file
systemctl daemon-reload
systemctl enable ${DIRECTORY}_autodelegate
systemctl restart ${DIRECTORY}_autodelegate

#journalctl -u ${DIRECTORY}_autodelegate -f -o cat
