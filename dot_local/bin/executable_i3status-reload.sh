#!/bin/sh

set -eu

if [ $# -ne 1 ]; then
	echo "Usage: $0 on/off"
	exit 1
fi

i3status_reload() {
	i3-msg -t command 'exec --no-startup-id killall i3bar'
	i3-msg -t command 'exec --no-startup-id i3bar --bar_id=bar-0'
}

ymd="%Y-%m-%d"
config=~/.config/i3status/config

if [ "$1" == "on" ]; then
	sed -i "s/^.*$ymd.*$/        format = '%Y-%m-%d %H:%M:%S'/" $config
else
	sed -i "s/^.*$ymd.*$/        format = '%Y-%m-%d'/" $config
fi

i3status_reload
