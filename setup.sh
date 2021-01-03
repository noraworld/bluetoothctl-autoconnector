#!/bin/bash

function register_crontab() {
  crontab $fullpath/cron.conf
  echo -e "crontab registered"
  echo -e "\033[2m"
  crontab -l
  echo -en "\033[00m"
}

fullpath=$(dirname $(realpath $0))
echo "*/1 * * * * $fullpath/autoconnector.sh" > $fullpath/cron.conf
if crontab -l 1>/dev/null 2>/dev/null; then
  echo -e "\033[1;33mCAUTION! YOU ARE ABOUT TO OVERWRITE THE EXISTING CRONTAB!!!\033[00m"
  echo -e "\033[2m"
  crontab -l
  echo -e "\033[00m"
  echo -en "Are you sure you want to overwrite? [YES/no]: "

  exec < /dev/tty
  read confirm
  echo

  if [[ $confirm = "YES" ]]; then
    register_crontab
  else
    echo -e "Canceled"
    echo -e "Add the following line to crontab manually"
    echo -e "\033[2m"
    cat $fullpath/cron.conf
    echo -en "\033[00m"
  fi
else
  register_crontab
fi
