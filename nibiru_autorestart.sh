#!/bin/bash

# make sure scripts is in path. If not then make dir
cd $HOME
mkdir -p "$HOME/scripts"

# write nibiru_autorestart.sh to scripts/
tee $HOME/scripts/nibiru_autorestart.sh > /dev/null <<EOF
#!/bin/sh

while true; do
  h1=$(nibid status 2>&1 | jq ."SyncInfo"."latest_block_height")
  echo "h1: $h1"

  sleep 10

  h2=$(nibid status 2>&1 | jq ."SyncInfo"."latest_block_height")
  echo "h2: $h2"

  if [ "$(echo "$h1 $h2" | awk '{print ($1 == $2)}')" -eq 1 ]; then
    systemctl restart nibid
    echo "systemctl restart nibid"
  fi

  sleep 3

done
EOF

# set run script rights
chmod +x $HOME/scripts/nibiru_autorestart.sh
# avoid error nibid command not found
sudo cp $HOME/go/bin/nibid /usr/local/bin/

# Create nibiru_autorestart service file (One command)
sudo tee /etc/systemd/system/nibiru_autorestart.service > /dev/null <<EOF
[Unit]
Description=Nibiru Autorestart Service
After=network.target

[Service]
User=$USER
ExecStart=$HOME/scripts/nibiru_autorestart.sh
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Start nibiru_autorestart service file
systemctl daemon-reload
# systemctl enable nibiru_autorestart.service
# systemctl restart nibiru_autorestart.service

