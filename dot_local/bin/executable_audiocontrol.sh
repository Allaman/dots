#! /usr/bin/env bash

# https://sourcecodeartisan.com/2020/12/03/i3-and-pulse-audio.html

set -eu

# Get the ID for the current DEFAULT_SINK
defaultSink=$(pactl info | grep "Default Sink: " | awk '{ print $3 }')

# Query the list of all available sinks
sinks=()
i=0
while read -r line; do
	index=$(echo "$line" | awk '{ print $1 }')
	sinks[${#sinks[@]}]=$index

	# Find the current DEFAULT_SINK
	if grep -q "$defaultSink" <<<"$line"; then
		defaultPos=$i
	fi

	i=$(($i + 1))
done <<<"$(pactl list sinks short)"

# Compute the ID of the new DEFAULT_SINK
newDefaultPos=$((($defaultPos + 1) % ${#sinks[@]}))
newDefaultSink=${sinks[$newDefaultPos]}

# Update the DEFAULT_SINK
pactl set-default-sink "$newDefaultSink"

# Move all current playing streams to the new DEFAULT_SINK
while read -r stream; do
	# Check whether there is a stream playing in the first place
	if [ -z "$stream" ]; then
		break
	fi

	streamId=$(echo "$stream" | awk '{ print $1 }')
	pactl move-sink-input "$streamId" @DEFAULT_SINK@
done <<<"$(pactl list short sink-inputs)"
