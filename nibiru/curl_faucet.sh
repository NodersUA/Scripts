#!/bin/bash

# source <(curl -s https://raw.githubusercontent.com/NodersUA/Scripts/main/nibiru/curl_faucet.sh)

tee $HOME/df_nibiru/curl_faucet.sh > /dev/null <<EOF
#!/bin/bash

sleep \$(shuf -i 0-21600 -n 1) # 6 годин рандома

while true
do
    date
    # Request tokens
    curl -X POST -d '{"address": "'"$(nibid keys show wallet -a)"'", "coins": ["110000000unibi","100000000unusd","100000000uusdt"]}' "https://faucet.itn-2.nibiru.fi/"
    sleep 87000 # Доба з запасом
    sleep \$(shuf -i 0-900 -n 1) # 15 хв рандома
    echo "===================================="
done
EOF

chmod +x $HOME/df_nibiru/curl_faucet.sh

# Create Diskord service file (One command)
sudo tee /etc/systemd/system/curl_nibiru.service > /dev/null <<EOF
[Unit]
Description=Nibiru curl faucet service
After=network.target

[Service]
User=$USER
ExecStart=$HOME/df_nibiru/curl_faucet.sh
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Start Diskord service file
systemctl daemon-reload
systemctl enable curl_nibiru
systemctl restart curl_nibiru
