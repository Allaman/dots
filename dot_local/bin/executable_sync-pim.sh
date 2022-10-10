#!/bin/bash

# Sync calendar and contacts via vdirsyncer

if [[ "$OSTYPE" =~ "darwin"* ]]
then
  export PATH=$HOME/Library/Python/3.8/bin:/opt/homebrew/opt/gnu-tar/libexec/gnubin/:/opt/homebrew/Cellar/coreutils/9.1/libexec/gnubin:/opt/homebrew/bin:$PATH
  export LC_CTYPE=UTF-8
fi

source $HOME/.local/bin/notify.sh

# Run only if user logged in (prevent cron errors)
pgrep -u "${USER:=$LOGNAME}" >/dev/null || { notify "$USER not logged in; sync will not run."; exit ;}
# Run only if not already running in other instance
pgrep -x vdirsyncer >/dev/null && { notify "vdirsyncer is already running." ; exit ;}

SYNC_INTERVAL=3600

while true
do
  vdirsyncer sync &>/dev/null; [ $? -eq 0 ] && : || notify "PIM Sync failed!"
  sleep $SYNC_INTERVAL
done

