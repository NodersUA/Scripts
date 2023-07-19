#!/bin/sh

# Функція для виконання команди з перевіркою на помилку sequence
execute_with_sequence_check() {
  cmd=$1
  expected_sequence=$(nibid query account $NIBIRU_ADDRESS | grep -oP '(?<=sequence: ")[^"]+' | awk '{print $1}')
  if [ -z "$sequence" ]; then sequence=$expected_sequence; else sequence=$(expr $sequence + 1); fi
  new_cmd="$cmd --sequence=$sequence -y"
  echo $new_cmd
  eval $new_cmd
  sleep 3
}

# Виконуємо команду та зберігаємо результат у змінну
output=$(nibid q oracle aggregate-votes | grep 'voter')

# Перевіряємо, чи змінна не є порожньою
while [ -z "$output" ]
do
  # Виконуємо команду ще раз та зберігаємо результат у змінну
  output=$(nibid q oracle aggregate-votes | grep 'voter')
  sleep 2
done

# Вибираємо 3 випадкові записи та видаляємо "voter: " з початку рядка
valoper1=$(echo "$output" | grep 'voter' | shuf -n 1 | sed 's/voter: //' | tr -d '[:space:]')
valoper2=$(echo "$output" | grep 'voter' | shuf -n 1 | sed 's/voter: //' | tr -d '[:space:]')
#valoper3=$(echo "$output" | grep 'voter' | shuf -n 1 | sed 's/voter: //' | tr -d '[:space:]')

# Виводимо результати
echo "Random Valoper 1: $valoper1"
echo "Random Valoper 2: $valoper2"
#echo "Random Valoper 3: $valoper3"

# Виконуємо команди з перевіркою на помилку sequence
execute_with_sequence_check "nibid tx staking delegate $valoper1 $(shuf -i 6000000-10000000 -n 1)unibi --from wallet --fees 7500unibi --gas=300000" # 2000000
execute_with_sequence_check "nibid tx staking delegate $NIBIRU_VALOPER $(shuf -i 6000000-10000000 -n 1)unibi --from wallet --fees 7500unibi --gas=300000" # 8000000
execute_with_sequence_check "nibid tx staking redelegate $NIBIRU_VALOPER $valoper2 $(shuf -i 1000000-3000000 -n 1)unibi --from wallet --fees 7500unibi --gas=300000" # 3000000
execute_with_sequence_check "nibid tx staking unbond $NIBIRU_VALOPER $(shuf -i 1000000-3000000 -n 1)unibi --from wallet --fees 7500unibi --gas=300000" # 2000000
execute_with_sequence_check "nibid tx distribution withdraw-all-rewards --from wallet --fees 7500unibi --gas=300000"
