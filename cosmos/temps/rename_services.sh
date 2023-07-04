#!/bin/bash

#systemctl stop nibiru_autodelegate && systemctl disable nibiru_autodelegate && sudo rm /etc/systemd/system/nibiru_autodelegate.service
#systemctl stop defund_autodelegate && systemctl disable defund_autodelegate && sudo rm /etc/systemd/system/defund_autodelegate.service
#systemctl stop cascadia_autodelegate && systemctl disable cascadia_autodelegate && sudo rm /etc/systemd/system/cascadia_autodelegate.service

systemctl stop nibiru_autorestart && systemctl disable nibiru_autorestart && sudo rm /etc/systemd/system/nibiru_autorestart.service
systemctl stop defund_autorestart && systemctl disable defund_autorestart && sudo rm /etc/systemd/system/defund_autorestart.service
systemctl stop cascadia_autorestart && systemctl disable cascadia_autorestart && sudo rm /etc/systemd/system/cascadia_autorestart.service


# update autorestart Defund
echo "8" | source <(curl -s https://raw.githubusercontent.com/NodersUA/Scripts/main/defund)
# update autorestart Nibiru
echo "8" | source <(curl -s https://raw.githubusercontent.com/NodersUA/Scripts/main/nibiru/nibiru)
# update autorestart Cascadia
echo "8" | source <(curl -s https://raw.githubusercontent.com/NodersUA/Scripts/main/cascadia)

