#!/bin/bash

### Description: Connects to a host via ssh from a selection of hosts provided by an ansible inventory
### Author:      Michael Peter
### Date:        20181121

# set -x
set -euo pipefail

tmpfile=$(mktemp)
for program in ansible-inventory awk sed grep sort uniq rm mktemp; do
  which "$program" > /dev/null || { error "Requires $program"; exit 1; }
done

parse_yaml() {
  local prefix=$2
  local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
  sed -ne "s|^\($s\)\($w\)$s:$s\"\(.*\)\"$s\$|\1$fs\2$fs\3|p" \
    -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p" $1 |
    awk -F$fs '{
  indent = length($1)/2;
  vname[indent] = $2;
  for (i in vname) {if (i > indent) {delete vname[i]}}
    if (length($3) > 0) {
      vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
      printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
    }
  }'
}

parse_inventory() {
  local inventory_file=$1
  if [ ! -f $inventory_file ]; then
    error "Not found: $inventory_file"
    exit 1
  fi
  ansible-inventory -i $inventory_file -y --list > $tmpfile
  inventory=$(parse_yaml $tmpfile "assh_" | sort | uniq)
  inv=$(printf -- '%s\n' "${inventory[@]}" | grep fqdn | awk -F= '{gsub(/assh_all_children_/,x); gsub(/_hosts__mx1_canonical_fqdn/,x); gsub(/"/,x); {print $2"("$1")"}}')
  if [ -z "$inv" ]; then
    inv=$(printf -- '%s\n' "${inventory[@]}" | grep mgmtip | awk -F= '{gsub(/assh_all_children_/,x); gsub(/_hosts__mgmtip/,x); gsub(/"/,x); {print $2"("$1")"}}')
  fi
  [[ -f $tmpfile ]] || rm $tmpfile
  echo $inv
}

connect_host() {
  arr=( $1 )
  [[ -z "$arr" ]] && { error "No hosts found!"; exit 1; }
  echo "Please select a host"
  select choice in "${arr[@]}"; do
    [[ -n $choice ]] || { echo "Invalid choice. Please try again." >&2; continue; }
    break
  done
  host=$(echo $choice | sed 's/(.*//g')
  ssh -o StrictHostKeyChecking=no $host
}

error() {
  echo "Error: $1" >&2
}

main() {
  if [ $# -eq 0 ]; then
    echo "Missing argument(s)"
    echo "Usage: $(basename $0) <inventory>"
    echo "Usage: $(basename $0) <inventory> con"
    exit 1
  fi

  if [ $# -eq 1 ]; then
    echo "Listing all hosts from inventory"
    parse_inventory $1
  fi

  if [ $# -ge 2 ]; then
    echo "Connect to a host"
    connect_host "$(parse_inventory $1)"
  fi
}

main $@
