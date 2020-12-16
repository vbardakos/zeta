#!/usr/bin/env bash

source trycatch.sh
source histogram.sh

link="http://archive.ics.uci.edu/ml/machine-learning-databases/bridges/bridges.data.version1"
cols="IDENTIF,RIVER,LOCATION,ERECTED,PURPOSE,LENGTH,LANES,CLEAR-G,T-OR-D,MATERIAL,SPAN,REL-L,TYPE"
file=$(echo $link | tr '/' '\n' | tail -1)

# download file if needed
# shellcheck disable=SC1009
if [ ! -f "$file" ]; then
  try {
    set +e
    curl --url "$link" --output "$file";
    echo "$file downloaded successfully!";
  } catch {
    echo "$file failed to download";
  }
else
  echo "$file already exists";
fi

# add column names if needed
line="$(head -1 $file)"
if [[ ! $line == $cols ]]; then

  echo "adding column names to $file...";
  sed -i "" -e $'1 i\\\n'"$cols" $file;

else
  echo "column names are already added to $file";
fi

# generate hist for PURPOSE/LENGTH
# get PURPOSE/LENGTH indices
c_arr=($(echo $cols | tr ',' ' '))
arr=("PURPOSE" "LENGTH")
for col in "${arr[@]}"; do
  for i in ${!c_arr[@]}; do
    if [ "${c_arr[i]}" == "$col" ]; then
      idx[$((i+1))]=$col
      break
    fi
  done
done

function nan_remover() {
  local Vec=("${@:2}")
  local Nan=$1

  for val in "${Vec[@]}"; do
    # shellcheck disable=SC2053
    if [[ $val != $Nan ]]; then
      new_arr+=("$val")
    fi
  done
  echo "${new_arr[@]}"
}

bin=10
for i in "${!idx[@]}"; do
  arr=($(cat bridges.data.version1 | cut -d ',' -f"$i" | tail -n +2))  # start @ line 2
  arr=($(nan_remover ? "${arr[@]}"))
  histogram "${idx[i]}" "$bin" "${arr[@]}"  # args: title bin_num array
done

# count values greater than 1000
arr=($(cat bridges.data.version1 | cut -d ',' -f6 | tail -n +2))
arr=($(nan_remover ? "${arr[@]}"))
lim=1000

# the same result can be found by histogram and (max-min)/(1000-min) bins
# but it's not guaranteed, since the histogram is not made to work with
# floats
declare -i total=0
for i in "${arr[@]}"; do
  if (( $i > $lim )); then
    (( total++ ))
  fi
done
echo "Total observations over 1000: $total"

# replace ? with 0
tr ? 0 < $file > bridges.data.new

type=($(cat bridges.data.new | cut -d ',' -f${#c_arr[@]} | tail -n +2))




