#!/usr/bin/env bash

my_var=$1
file="bridges.data.new"

cols=($(head -1 $file | tr "," " "))
length=($(cat $file | cut -d ',' -f6 | tail -n +2))
type=($(cat $file | cut -d ',' -f13 | tail -n +2))

declare -i counter=0
for i in "${!type[@]}"; do
  if [[ "${type[i]}" == "$my_var" ]]; then
    counter=$(( counter+length[i] ))
  fi
done

echo "TOTAL LENGTH OF $my_var BRIDGES: $counter";
