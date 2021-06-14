#!/bin/bash

# WARNING: Changing this file will affect cron immediately

fullpath=$(dirname $(realpath $0))

(
  echo "=================================== $(date) ==================================="
  $fullpath/autoconnector.sh | sed -E 's/\xd$//g' # sed: replace the last "^M" with "\n"
  echo "===================================================================================================="
  echo
) >> $fullpath/log/`date '+%Y-%m-%d'`.log 2>&1

# create symlink of the latest log file as file name "latest.log"
ln -sf $fullpath/log/`date '+%Y-%m-%d'`.log $fullpath/log/latest.log
