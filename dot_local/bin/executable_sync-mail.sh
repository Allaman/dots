#!/bin/bash

# Aapted from https://github.com/LukeSmithxyz/mutt-wizard/blob/master/bin/mailsync

# Sync all mail accounts via mbsync
# Run notmuch

# Add MacOS specified PATHs
if [[ "$OSTYPE" =~ "darwin"* ]]
then
  export PATH=$HOME/Library/Python/3.8/bin:/opt/homebrew/opt/gnu-tar/libexec/gnubin/:/opt/homebrew/Cellar/coreutils/9.1/libexec/gnubin:/opt/homebrew/bin:$PATH
  export LC_CTYPE=UTF-8
fi

# Run only if user logged in (prevent cron errors)
pgrep -u "${USER:=$LOGNAME}" >/dev/null || { echo "$USER not logged in; sync will not run."; exit ;}
# Run only if not already running in other instance
pgrep -x mbsync >/dev/null && { echo "mbsync is already running." ; exit ;}

MBSYNCRC="$HOME/.mbsyncrc"
SYNC_INTERVAL=600

# if [[ "$OSTYPE" =~  *"linux"* ]]
# then
#   displays="$(pgrep -a Xorg | grep -wo "[0-9]*:[0-9]\+" | sort -u)"
#   notify() {
#     for x in $displays; do
#       export DISPLAY=$x
#       notify-send --app-name="mailsync" "mailsync" "📬 $2 new mail(s) in \`$1\` account."
#     done ;}
#     messageinfo() {
#       for x in $displays; do
#         export DISPLAY=$x
#         notify-send --app-name="mailsync" "📧$from:" "$subject"
#       done ;}
# else
#   notify() {
#     osascript -e "display notification \"$2 new mail(s) in $1\" with title \"mailsync\""
#   }
#   messageinfo() {
#     osascript -e "display notification \"$from\" with title \"mailsync\""
#   }
# fi


# Check account for new mail. Notify if there is new content.
syncandnotify() {
  acc="$(echo "$account" | sed "s/.*\///")"
  if [ -z "$opts" ]; then mbsync "$acc"; else mbsync "$opts" "$acc"; fi
  new=$(find "$HOME/pim/mail/$acc/INBOX/new/" "$HOME/pim/mail/$acc/Inbox/new/" "$HOME/pim/mail/$acc/inbox/new/" -type f -newer "$HOME/.mutt/mailsynclastrun" 2> /dev/null)
  newcount=$(echo "$new" | sed '/^\s*$/d' | wc -l)
  if [ "$newcount" -gt "0" ]; then
    # notify "$acc" "$newcount" &
    for file in $new; do
      # Extract subject and sender from mail.
      from=$(awk '/^From: / && ++n ==1,/^\<.*\>:/' "$file" | perl -CS -MEncode -ne 'print decode("MIME-Header", $_)' | awk '{ $1=""; if (NF>=3)$NF=""; print $0 }' | sed 's/^[[:blank:]]*[\"'\''\<]*//;s/[\"'\''\>]*[[:blank:]]*$//')
      subject=$(awk '/^Subject: / && ++n == 1,/^\<.*\>: / && ++i == 2' "$file" | head -n 1 | perl -CS -MEncode -ne 'print decode("MIME-Header", $_)' | sed 's/^Subject: //' | sed 's/^{[[:blank:]]*[\"'\''\<]*//;s/[\"'\''\>]*[[:blank:]]*$//' | tr -d '\n')
      messageinfo &
    done
      fi
    }


  while true
  do
    # Sync accounts passed as argument or all.
    if [ "$#" -eq "0" ]; then
      accounts="$(awk '/^Channel/ {print $2}' "$MBSYNCRC")"
    else
      for arg in "$@"; do
        [ "${arg%${arg#?}}" = '-' ] && opts="${opts:+${opts} }${arg}" && shift 1
      done
      accounts=$*
    fi
    # Parallelize multiple accounts
    for account in $accounts; do
      syncandnotify &
    done
    wait
    notmuch new 2>/dev/null
    #Create a touch file that indicates the time of the last run of mailsync
    touch "$HOME/.mutt/mailsynclastrun"
    sleep $SYNC_INTERVAL
  done
