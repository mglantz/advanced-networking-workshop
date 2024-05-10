#!/usr/bin/bash
# Create Ansible inventory from the containerlab output
# Magnus Glantz, sudo@redhat.com, 2024

install_dir="$HOME/advanced-networking-workshop"
inventory_file="$install_dir/inventory"

cat << 'EOF' >$inventory_file
[all:vars]
# common variables
ansible_user=admin
ansible_ssh_private_key_file=~/.ssh/advanced-networking-workshop_id_rsa
ansible_network_os=arista.eos.eos
ansible_connection=ansible.netcommon.network_cli

EOF

case $1 in
	lab1|--lab1|LAB1|Lab1)
		if [ ! -f $install_dir/containerlab/lab1.yml ]
		then
        		echo "Please name your topology file lab1.yml and place it in $install_dir/containerlab/"
			exit 1
		fi
		echo "[leafs]" >>$inventory_file
		sudo containerlab inspect -t $install_dir/containerlab/lab1.yml 2>/dev/null|grep clab|cut -d'|' -f3,8| sed -e "s@/24@@g" -e "s/ //g" -e "s/|/ ansible_host=/g"|grep leaf >>$inventory_file
		;;
	lab2|--lab2|LAB2|Lab2)
                if [ ! -f $install_dir/containerlab/lab2.yml ]
                then
                        echo "Please name your topology file lab2.yml and place it in $install_dir/containerlab/"
                        exit 1
                fi

                echo "[leafs]" >>$inventory_file
                sudo containerlab inspect -t $install_dir/containerlab/lab2.yml 2>/dev/null|grep clab|cut -d'|' -f3,8| sed -e "s@/24@@g" -e "s/ //g" -e "s/|/ ansible_host=/g"|grep leaf >>$inventory_file
                echo "" >>$inventory_file
                echo "[spines]" >>$inventory_file
                sudo containerlab inspect -t $install_dir/containerlab/lab2.yml 2>/dev/null|grep clab|cut -d'|' -f3,8| sed -e "s@/24@@g" -e "s/ //g" -e "s/|/ ansible_host=/g"|grep spine >>$inventory_file

                echo "" >>$inventory_file
                echo "[switches:children]" >>$inventory_file
                echo "leafs" >>$inventory_file
                echo "spines" >>$inventory_file
		;;
	lab3-full|--lab3-full|LAB3-FULL|lab3|LAB3)
		echo "[linux]" >>$inventory_file
		sudo containerlab inspect -t $install_dir/containerlab/lab3-full.yml 2>/dev/null|cut -d'|' -f3,8|grep clab | grep host|sed -e "s@/24@@g" -e "s/ //g" -e "s/|/ ansible_host=/g" >>$inventory_file

		echo "" >>$inventory_file
		echo "[leafs]" >>$inventory_file
		sudo containerlab inspect -t $install_dir/containerlab/lab3-full.yml 2>/dev/null|cut -d'|' -f3,8|grep clab | sed -e "s@/24@@g" -e "s/ //g" -e "s/|/ ansible_host=/g"|grep leaf >>$inventory_file

		echo "" >>$inventory_file
		echo "[spines]" >>$inventory_file
		sudo containerlab inspect -t $install_dir/containerlab/lab3-full.yml 2>/dev/null|cut -d'|' -f3,8|grep clab | sed -e "s@/24@@g" -e "s/ //g" -e "s/|/ ansible_host=/g"|grep spine >>$inventory_file

		echo "" >>$inventory_file
		echo "[switches:children]" >>$inventory_file
		echo "leafs" >>$inventory_file
		echo "spines" >>$inventory_file
		;;
esac

$install_dir/scripts/fingerprints.sh 2>/dev/null
