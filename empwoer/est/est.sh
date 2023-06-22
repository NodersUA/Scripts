#!/bin/bash

count=200
timeout=$((3600 / count - 10))
#echo $timeout

sleep $(shuf -i 60-120 -n 1)

execute_with_sequence_check() {
  cmd=$1
  wallet=$(empowerd keys show wallet -a)
  sequence=$(empowerd query account $wallet | grep -oP '(?<=sequence: ")[^"]+' | awk '{print $1}')
  new_cmd="$cmd --sequence=$sequence -y"
  echo $new_cmd
  eval $new_cmd
  sleep=$(shuf -i $((timeout - 5))-$((timeout + 5)) -n 1)
  echo "sleep: ${sleep} sec"
  sleep $sleep
}

for ((i=1; i<=$count; i++))
do

denom=$(shuf -n 1 credits.txt)
echo ">>> Credit ${i}: ${denom}"

# buy credit
execute_with_sequence_check "empowerd tx wasm execute empower14hj2tavq8fpesdwxxcu44rty3hh90vhujrvcmstl4zr3txmfvw9sfg4umu '{\"buy_credits\":{\"owner\":\"empower10meawsx9u3lkl2p6amk87k6tye6qn6dkqx2ksj\",\"denom\":\"${denom}\",\"number_of_credits_to_buy\":1}}' --amount 500000umpwr --from wallet --gas 500000 --fees $(shuf -i 50-150 -n 1)00umpwr"

if [ $(shuf -i 1-2 -n 1) == 1 ]; then
echo "tranfer credit"
# tranfer credit
execute_with_sequence_check "empowerd tx plasticcredit transfer ${wallet} empower175p8jy5fcdkpm3djk40p8ucdn3lyjyd7jtf77w ${denom} 1 false --gas 500000 --fees $(shuf -i 50-150 -n 1)00umpwr"
else
echo "retire credit"
# retire
execute_with_sequence_check "empowerd tx plasticcredit retire $denom 1 $MONIKER test --from wallet --gas 500000 --fees $(shuf -i 50-150 -n 1)00umpwr"
fi

done
