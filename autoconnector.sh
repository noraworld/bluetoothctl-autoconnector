#!/bin/bash

PROGNAME=$(basename $0)

function usage() {
  echo -e "Usage: $PROGNAME [-h]"
  printf  "       %${#PROGNAME}s [-f FILE]\n"
  echo
  echo -e "Description:"
  echo -e "  Attempt to connect all paired Bluetooth devices"
  echo
  echo -e "Options:"
  echo -e "  -h, --help"
  echo -e "    Show this help message and exit"
  echo -e "  -f FILE, --file FILE"
  echo -e "    Attempt to connect only specific devices written in mapping list file"
  echo -e "    For details on how to write a mapping list file, see list.sample"
}

is_mapping_file=false
for opt in "$@"
do
  case "$opt" in
    '-h' | '--help' )
      usage
      exit 0
    ;;
    '-f' | '--file' )
      if [[ -z "$2" ]] || [[ "$2" =~ ^-+ ]]; then
        echo "$PROGNAME: option requires an argument -- $1" 1>&2
        exit 1
      fi
      FILE=$2
      is_mapping_file=true
      shift 2
    ;;
    '--' | '-' )
      shift 1
      param+=( "$@" )
      break
    ;;
    -* )
      echo "$PROGNAME: illegal option -- '$(echo $1 | sed 's/^-*//')'" 1>&2
      exit 1
    ;;
    * )
      if [[ ! -z "$1" ]] && [[ ! "$1" =~ ^-+ ]]; then
        param+=( "$1" )
        shift 1
      fi
    ;;
  esac
done

# returns devices’ BD addresses paired with selected adapter
function paired_devices() {
  {
    printf "select $adapter\n\n"
    printf "paired-devices\n\n"
  } | bluetoothctl | grep "Device " | sed -r 's/^.*(([0-9A-F]{2}:){5}[0-9A-F]{2}).*$/\1/'
}

# checks if the device is being connected
# returns 'yes' or 'no'
function is_connected() {
  {
    printf "select $adapter\n\n"
    printf "info $device\n\n"
  } | bluetoothctl | grep "Connected: " | sed -e 's/Connected: //' | sed -e 's/^[[:blank:]]*//'
}

# connects devices
if ! $is_mapping_file; then # attempts to connect all devices
  bluetoothctl -- list | while read line
  do
    adapter=`echo $line | sed -r 's/^.*(([0-9A-F]{2}:){5}[0-9A-F]{2}).*$/\1/'`

    paired_devices | while read device
    do
      if [[ $(is_connected) = "no" ]]; then
        {
          printf "select $adapter\n\n"
          printf "connect $device\n\n"
        } | bluetoothctl
      fi
    done
  done
else # attempts to connect specific devices written in mapping list
  while read line
  do
    # skip a comment line and a blank line
    if ! [[ $line =~ ^# ]] && ! [[ $line =~ ^([[:blank:]]+.*)*$ ]]; then
      # save Bluetooth adapter’s BD address and device’s BD address
      adapter=`echo "$line," | cut -d ',' -f 1`
      device=`echo "$line," | cut -d ',' -f 2`

      # connect the device if not connected
      if [[ $(is_connected) = "no" ]]; then
        {
          printf "select $adapter\n\n"
          printf "connect $device\n\n"
        } | bluetoothctl
      fi
    fi
  done < $FILE
fi
