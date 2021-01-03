#!/bin/bash

function is_connected() {
  {
    printf "select $adapter\n\n"
    printf "info $device\n\n"
  } | bluetoothctl | grep "Connected: " | sed -e 's/Connected: //' | sed -e 's/^[[:blank:]]*//'
}

while read line
do
  # skip comment lines and blank lines
  if ! [[ $line =~ ^# ]] && ! [[ $line =~ ^([[:blank:]]+.*)*$ ]]; then
    # Save Bluetooth adapter’s MAC address and device’s MAC address
    adapter=`echo "$line," | cut -d ',' -f 1`
    device=`echo "$line," | cut -d ',' -f 2`

    if [[ $(is_connected) = "no" ]]; then
      {
        printf "select $adapter\n\n"
        printf "connect $device\n\n"
      } | bluetoothctl
    fi
  fi
done < ./list
