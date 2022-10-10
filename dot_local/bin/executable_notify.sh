#!/bin/bash

function notify {
  if [[ "$OSTYPE" =~ "darwin"* ]]
    then
      osascript -e "display notification \"$1\" with title \"Notify\""
    else
  	if [[ -z "${DISPLAY// }" ]]
  	then
  		# no x server detected
  		echo "$1"
  	elif ! [[ -z "${DISPLAY// }" ]]
  	then
  		# x server detected
  		notify-send "$1"
  	else
  		# error
  		echo "Cannot check for running x server"
  		exit 1
  	fi
  fi
}
