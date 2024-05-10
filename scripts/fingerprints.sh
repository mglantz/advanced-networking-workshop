#!/usr/bin/bash
# Accept fingerprints based on ansible inventory
# Magnus Glantz, sudo@redhat.com, 2024

install_dir="$HOME/advanced-networking-workshop"
inventory_file="$install_dir/inventory"

cat $inventory_file | grep host | cut -d '=' -f 2 | xargs ssh-keyscan -H >> ~/.ssh/known_hosts
