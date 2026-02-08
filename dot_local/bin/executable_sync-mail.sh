#!/usr/bin/env bash

export PATH="/usr/local/bin:/usr/bin:/bin:/opt/homebrew/bin:$PATH"

MBSYNC=$(which mbsync)
if [ -z "$MBSYNC" ]; then
  echo "mbsync not found in PATH: $PATH"
  exit 1
fi

NOTMUCH=$(which notmuch)
if [ -z "$NOTMUCH" ]; then
  echo "notmuch not found in PATH: $PATH"
  exit 1
fi

notify() {
  if [ "$(uname -s)" == "Darwin" ]; then
    osascript -e "display notification \"$1\" with title \"Mail Sync\""
  else
    notify-send "Mail Sync" "$1"
  fi
}

# Wait for network
while ! ping -c 1 -W 1 8.8.8.8 &>/dev/null; do
  sleep 5
done

# Run mbsync and capture output
OUTPUT=$($MBSYNC -a 2>&1)
EXIT_CODE=$?

if [ $EXIT_CODE -ne 0 ]; then
  notify "Sync failed: $OUTPUT"
  exit $EXIT_CODE
fi

OUTPUT=$($NOTMUCH new 2>&1)
EXIT_CODE=$?

if [ $EXIT_CODE -ne 0 ]; then
  notify "notmuch failed: $OUTPUT"
  exit $EXIT_CODE
fi
