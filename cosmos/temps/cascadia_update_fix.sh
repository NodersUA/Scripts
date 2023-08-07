#!/bin/bash

# source <(curl -s https://raw.githubusercontent.com/NodersUA/Scripts/main/cosmos/temps/cascadia_update_fix.sh)

systemctl stop cascadiad
cd /usr/local/bin/
curl -L https://github.com/CascadiaFoundation/cascadia/releases/download/v0.1.4/cascadiad -o cascadiad
chmod +x cascadiad && cd

sudo tee /etc/systemd/system/cascadiad.service > /dev/null <<EOF
[Unit]
Description=Cascadia Node
After=network.target
 
[Service]
Type=simple
User=$USER
WorkingDirectory=$HOME/go/bin
ExecStart=/usr/local/bin/cascadiad start --trace --log_level info --json-rpc.api eth,txpool,personal,net,debug,web3 --api.enable
Restart=on-failure
StartLimitInterval=0
RestartSec=3
LimitNOFILE=65535
LimitMEMLOCK=209715200
 
[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload

echo "3" | source <(curl -s https://raw.githubusercontent.com/NodersUA/Scripts/main/cascadia)
