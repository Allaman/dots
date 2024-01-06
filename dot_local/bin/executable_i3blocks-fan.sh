#!/usr/bin/env bash

FANSPEED=$(cat /proc/acpi/ibm/fan | awk 'NR==2 {print $2}')

# Full and short texts
echo "Fan: $FANSPEED rpm"
echo "$FANSPEED"

exit 0
