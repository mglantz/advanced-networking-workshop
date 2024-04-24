#!/usr/bin/bash
# Create Ansible inventory from the containerlab output
# Magnus Glantz, sudo@redhat.com, 2024

install_dir="/home/mglantz/advanced-networking-workshop"
inventory_file="$install_dir/inventory"

cat << 'EOF' >$inventory_file
[all:vars]
# common variables
ansible_user=admin
ansible_ssh_private_key_file=~/.ssh/advanced-networking-workshop_id_rsa
ansible_network_os=arista.eos.eos
ansible_connection=ansible.netcommon.httpapi
EOF

echo "[linux]" >>$inventory_file
sudo containerlab inspect -t $install_dir/containerlab/ceos-evpn-overlaid.clab.yml 2>/dev/null|cut -d'|' -f3,8|grep clab-EVPN | grep host|sed -e "s@/24@@g" -e "s/ //g" -e "s/|/ ansible_host=/g" >>$inventory_file

echo "" >>$inventory_file
echo "[leafs]" >>$inventory_file
sudo containerlab inspect -t $install_dir/containerlab/ceos-evpn-overlaid.clab.yml 2>/dev/null|cut -d'|' -f3,8|grep clab-EVPN | sed -e "s@/24@@g" -e "s/ //g" -e "s/|/ ansible_host=/g"|grep leaf >>$inventory_file

echo "" >>$inventory_file
echo "[spines]" >>$inventory_file
sudo containerlab inspect -t $install_dir/containerlab/ceos-evpn-overlaid.clab.yml 2>/dev/null|cut -d'|' -f3,8|grep clab-EVPN | sed -e "s@/24@@g" -e "s/ //g" -e "s/|/ ansible_host=/g"|grep spine >>$inventory_file

echo "" >>$inventory_file
echo "[switches:children]" >>$inventory_file
echo "leafs" >>$inventory_file
echo "spines" >>$inventory_file
