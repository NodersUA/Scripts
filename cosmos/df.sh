#!/bin/bash

cd $HOME
if [ -d "$DISCORD_DIR" ]; then
    rm -rf "$DISCORD_DIR"
fi

#if [ -z "$PROJECT_TOKEN" ]; then
  echo "*********************"
  echo -e "\e[1m\e[32m	Enter your Diskord Token:\e[0m"
  echo "_|-_|-_|-_|-_|-_|-_|"
  read PROJECT_TOKEN
  echo "_|-_|-_|-_|-_|-_|-_|"
  echo 'export '$PROJECT'_TOKEN='$PROJECT_TOKEN >> $HOME/.bash_profile
  source $HOME/.bash_profile
#fi

# Add discord bot
apt install pip -y
cd $HOME && git clone https://github.com/TechCryptoBots/Discord-Whitelist-Bot.git $DISCORD_DIR
cd $DISCORD_DIR
pip install -r requirements.txt
cd $HOME

# Settings discord bot
tee $HOME/$DISCORD_DIR/src/config/accounts.txt > /dev/null <<EOF
$PROJECT_TOKEN
EOF

# \$request $ADDRESS = MESSAGE
tee $HOME/$DISCORD_DIR/src/config/messages.txt > /dev/null <<EOF
$MESSAGE
EOF

tee $HOME/$DISCORD_DIR/src/config/config.yaml > /dev/null <<EOF
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

if [ "$DISCORD_DIR" == "df_side" ]; then sl=1; else sl=$(shuf -i 0-10000 -n 1); fi
echo "Sleep $sl sec..."

if [ "$DISCORD_DIR" == "df_babylon" ] || [ "$DISCORD_DIR" == "df_babylon_sbtc" ]; then sl1=21600; else sl1=86400; fi

tee $HOME/$DISCORD_DIR/db.sh > /dev/null <<EOF
#!/bin/bash

sleep $sl

while true
do
    date
    cd $HOME/$DISCORD_DIR/src/ && python3 main.py
    sleep $sl1
    sleep \$(shuf -i 0-1800 -n 1) # 30 хв рандома
    echo "===================================="
done
EOF

chmod +x $HOME/$DISCORD_DIR/db.sh

# Create Diskord service file (One command)
sudo tee /etc/systemd/system/$DISCORD_DIR.service > /dev/null <<EOF
[Unit]
Description=$DISCORD_DIR Autorestart Service
After=network.target

[Service]
User=$USER
ExecStart=$HOME/$DISCORD_DIR/db.sh
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Start Diskord service file
systemctl daemon-reload
systemctl enable $DISCORD_DIR
systemctl restart $DISCORD_DIR

#if [ "$DISCORD_DIR" == "df_penumbra" ]; then
#sleep $((sl + 600)) && echo "3" | source <(curl -s https://raw.githubusercontent.com/NodersUA/Scripts/main/penumbra)
#fi
