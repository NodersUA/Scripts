#!/bin/bash

cd $HOME
if [ -d "$DISKORD_DIR" ]; then
    rm -rf "$DISKORD_DIR"
fi

if [ -z "$TOKEN" ]; then
  echo "*********************"
  echo -e "\e[1m\e[32m	Enter your Diskord Token:\e[0m"
  echo "_|-_|-_|-_|-_|-_|-_|"
  read TOKEN
  echo "_|-_|-_|-_|-_|-_|-_|"
  echo 'export TOKEN='$TOKEN >> $HOME/.bash_profile
fi
source $HOME/.bash_profile

# Add discord bot
apt install pip -y
cd $HOME && git clone https://github.com/TechCryptoBots/Discord-Whitelist-Bot.git $DISKORD_DIR
cd $DISKORD_DIR
pip install -r requirements.txt
cd $HOME

# Settings discord bot
tee $HOME/$DISKORD_DIR/src/config/accounts.txt > /dev/null <<EOF
$TOKEN
EOF

# \$request $ADDRESS = MESSAGE
tee $HOME/$DISKORD_DIR/src/config/messages.txt > /dev/null <<EOF
$MESSAGE
EOF

tee $HOME/$DISKORD_DIR/src/config/config.yaml > /dev/null <<EOF
messages_file: config/messages.txt
accounts_file: config/accounts.txt
chat_id: $CHAT_ID
use_proxy: False
proxy_file: config/proxy.txt
send_delay: 10
log_send: True
log_read: False
log_tg: False
read_delay: 0.1
typing_delay_per_character: 2
EOF

tee $HOME/$DISKORD_DIR/db.sh > /dev/null <<EOF
#!/bin/bash

sleep $(shuf -i 0-9999 -n 1) # 3 години рандома

while true
do
    date
    cd $HOME/$DISKORD_DIR/src/ && python3 main.py
    sleep 86600
    sleep $(shuf -i 0-1800 -n 1) # Півгодини рандома
    echo "===================================="
done
EOF

chmod +x $HOME/$DISKORD_DIR/db.sh

# Create Diskord service file (One command)
sudo tee /etc/systemd/system/$DISKORD_DIR.service > /dev/null <<EOF
[Unit]
Description=$DISKORD_DIR Autorestart Service
After=network.target

[Service]
User=$USER
ExecStart=$HOME/$DISKORD_DIR/db.sh
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Start Diskord service file
systemctl daemon-reload
#systemctl enable $DISKORD_DIR
#systemctl restart $DISKORD_DIR
