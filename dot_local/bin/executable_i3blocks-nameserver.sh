#!/usr/bin/env bash

NAMESERVER=$(cat /etc/resolv.conf | grep nameserver | awk 'NR==1{print $2}')

# Full and short texts
echo "Nameserver: $NAMESERVER"
echo "NS: ***."${NAMESERVER##*.}""

exit 0
