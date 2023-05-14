#!/bin/bash

cd $HOME

echo "DIRECTORY: $DIRECTORY"
echo "BINARY_NAME: $BINARY_NAME"

# make sure scripts is in path. If not then make dir
mkdir -p "$HOME/scripts"

# write nibiru_autorestart.sh to scripts/
tee $HOME/scripts/$DIRECTORY_autorestart.sh > /dev/null <<EOF
#!/bin/sh

while true; do
  h1=\$($BINARY_NAME status 2>&1 | jq ."SyncInfo"."latest_block_height")
  echo "h1: \$h1"

  sleep 10

  h2=\$($BINARY_NAME status 2>&1 | jq ."SyncInfo"."latest_block_height")
  echo "h2: \$h2"

  if [ "\$(echo "\$h1 \$h2" | awk '{print (\$1 == \$2)}')" -eq 1 ]; then
    systemctl restart $BINARY_NAME
    echo "systemctl restart $BINARY_NAME"
  fi

  sleep 3

done
EOF

# set run script rights
chmod +x $HOME/scripts/$DIRECTORY_autorestart.sh
# avoid error <BINARY_NAME> command not found
sudo cp $HOME/go/bin/$BINARY_NAME /usr/local/bin/

# Create <DIRECTORY>_autorestart service file (One command)
sudo tee /etc/systemd/system/$DIRECTORY_autorestart.service > /dev/null <<EOF
[Unit]
Description=$DIRECTORY Autorestart Service
After=network.target

[Service]
User=$USER
ExecStart=$HOME/scripts/$DIRECTORY_autorestart.sh
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Start <DIRECTORY>_autorestart service file
systemctl daemon-reload
systemctl enable $DIRECTORY_autorestart.service
systemctl restart $DIRECTORY_autorestart.service

