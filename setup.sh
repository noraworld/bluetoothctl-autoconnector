#!/bin/bash

function register_crontab() {
  crontab $fullpath/cron.conf
  echo -e "crontab registered"
  echo -e "\033[2m"
  crontab -l
  echo -en "\033[00m"
}

fullpath=$(dirname $(realpath $0))

# YOU NEED TO DELETE EXISTING CRONTAB FOR AUTOCONNECTOR IF YOU CHANGE THE VALUE OF "autoconnector_crontab"
autoconnector_crontab="*/1 * * * * $fullpath/cron.sh"

# check if crontab for autoconnector is registered
while read line
do
  if [[ "$line" = "$autoconnector_crontab" ]]; then
    echo "Error: crontab for autoconnector already registered" >&2
    exit 2
  fi
done << FILE
  $(crontab -l 2>/dev/null)
FILE

if [[ $(crontab -l 2>/dev/null) == "" ]]; then
  echo "$autoconnector_crontab" > $fullpath/cron.conf
else
  echo -e "$(crontab -l 2>/dev/null)\n\n$autoconnector_crontab" > $fullpath/cron.conf
fi

register_crontab
rm $fullpath/cron.conf
