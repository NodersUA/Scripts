#!/bin/bash

# update autorestart Defund
echo "8" | source <(curl -s https://raw.githubusercontent.com/NodersUA/Scripts/main/defund)
# update autorestart Nibiru
echo "8" | source <(curl -s https://raw.githubusercontent.com/NodersUA/Scripts/main/nibiru/nibiru)
# update autorestart Cascadia
echo "8" | source <(curl -s https://raw.githubusercontent.com/NodersUA/Scripts/main/cascadia)
