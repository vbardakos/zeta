#!/usr/bin/env bash

# shellcheck disable=SC2120
function intervals() {
  local Bin=$1
  local Vec=("${@:2}")
  local uni=($(echo "${Vec[@]}" | tr " " "\n" | sort -u)) # sort expects new lines
  checker=true                                            # checker if Vec[@] are int

  # if bins int & gt 0
  if [ "$Bin" -gt 1 ] && [ "$Bin" -lt ${#Vec[@]} ]; then
    for u in "${uni[@]}"; do
      # if any observation not int
      if ! [ "$u" -eq "$u" ]; then
        checker=false
        break
      fi
    done
  else
    checker=false
  fi

  if $checker; then
    local M=${Vec[0]}
    local m=${Vec[0]}

    for n in "${Vec[@]}"; do
      ((n > M)) && M=$n
      ((n < m)) && m=$n
    done
    local size=$(((M - m) / Bin))
    # shellcheck disable=SC2004
    local size=$(($size + (1 - $size % 1)))
    for ((i = 0; i <= Bin; i++)); do
      i_array+=($((m + i * size)))
    done
  else
    i_array=("${uni[@]}")
  fi
}


function histogram() {
  local Bin=$2
  local Vec=("${@:3}")
  intervals "$Bin" "${Vec[@]}"
  declare -a hist

  for n in "${Vec[@]}"; do
    declare -i i=0
    if $checker; then
      while (($n >= ${i_array[i]})); do
        i+=1
      done
    else
      while [[ $n != "${i_array[i]}" ]]; do
        i+=1
      done
    fi
    hist[i]+="="
  done

  echo; echo "TITLE: $1"
  for i in "${!hist[@]}"; do
    if $checker; then
      echo "${i_array[i - 1]}"-"${i_array[i]}": ${hist[i]}
    else
      echo "${i_array[i]}": "${hist[i]}"
    fi
  done
}
