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
  echo -e "  -i, --ignore-sound"
  echo -e "    Ignore devices playing sounds"
  echo -e "    When some devices that have already connected to Bluetooth adapters are playing sounds,"
  echo -e "    bluetoothctl attempts to connect other device, and then the sounds breaks up temporarily"
  echo -e "    To avoid this, this script does not connect any device by default"
  echo -e "    when some devices that have already connected to Bluetooth adapters are playing sounds"
}

is_mapping_file=false
ignore_sound=false

for opt in "$@"
do
  case "$opt" in
    '-h' | '--help' )
      usage
      exit 0
    ;;
    '-i' | '--ignore-sound' )
      ignore_sound=true
      shift 1
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

# checks whether some devices play sound or not
# returns integer of 0 or more (the number of devices playing sound)
function is_playing() {
  # PULSE_RUNTIME_PATH environment variable is necessary
  # crontab does not recognize the PulseAudio daemon if PULSE_RUNTIME_PATH is missing
  #
  # Error message:
  #   pacmd:
  #     No PulseAudio daemon running, or not running as session daemon.
  #   pactl:
  #     Connection failure: Connection refused
  #     pa_context_connect() failed: Connection refused
  #
  # cf. https://superuser.com/questions/1207581/pacmd-why-doesnt-it-work-from-cron#answer-1243363
  export PULSE_RUNTIME_PATH="/run/user/$(id -u)/pulse/"

  # Both pacmd or pactl are fine
  pacmd list-sink-inputs | grep -c "state: RUNNING"
  # pactl list sink-inputs | grep -c -E "Sink Input #[0-9]{1,}"
}

# connects devices
if ! $is_mapping_file; then # attempts to connect all devices
  if ! $ignore_sound && [[ $(is_playing) -gt 0 ]]; then
    echo -e "Error: Some devices now playing sounds" >&2
    echo -e "Specify option -i to ignore devices playing sounds" >&2
    exit 2
  fi

  bluetoothctl -- list | while read line
  do
    adapter=`echo $line | sed -r 's/^.*(([0-9A-F]{2}:){5}[0-9A-F]{2}).*$/\1/'`

    paired_devices | while read device
    do
      if [[ $(is_connected) = "no" ]]; then
        {
          printf "select $adapter\n\n"
          printf "power on\n\n"
          # sleep 2
          printf "connect $device\n\n"
          # sleep 4
        } | bluetoothctl

        echo
      fi
    done
  done
else # attempts to connect specific devices written in mapping list
  if ! $ignore_sound && [[ $(is_playing) -gt 0 ]]; then
    echo -e "Error: Some devices now playing sounds" >&2
    echo -e "Specify option -i to ignore devices playing sounds" >&2
    exit 2
  fi

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
