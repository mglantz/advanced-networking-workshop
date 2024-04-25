#!/usr/bin/bash
# Lab management script
# Magnus Glantz, sudo@redhat.com, 2024

install_dir="/home/mglantz/advanced-networking-workshop"
containerlab_file_start="$install_dir/containerlab/ceos-evpn-overload.clab-start.yml"
containerlab_file_full="$install_dir/containerlab/ceos-evpn-overload.clab-full.yml"

cd $install_dir/containerlab

start_lab()
{
	sudo containerlab --runtime podman deploy -t ceos-evpn-overlaid.clab-start.yml --reconfigure
	sh $install_dir/scripts/ansible_host.sh
	sh $install_dir/scripts/fingerprint.sh >/dev/null 2>&1
	cp $install_dir/scripts/id_rsa ~/.ssh/advanced-networking-workshop_id_rsa
	chmod ~/.ssh/advanced-networking-workshop_id_rsa
	ssh-add ~/.ssh/advanced-networking-workshop_id_rsa
}

start_lab_full()
{
        sudo containerlab --runtime podman deploy -t ceos-evpn-overlaid.clab-ful.yml --reconfigure
        sh $install_dir/scripts/ansible_host.sh
        sh $install_dir/scripts/fingerprint.sh >/dev/null 2>&1
	cp $install_dir/scripts/id_rsa ~/.ssh/advanced-networking-workshop_id_rsa
        chmod ~/.ssh/advanced-networking-workshop_id_rsa
        ssh-add ~/.ssh/advanced-networking-workshop_id_rsa
}

print_usage()
{
	echo "Usage: $0 [-s|-sf|--start|--start-full|help]"
	echo "-s|--start :: start lab"
	echo "-sf|--start-full :: start lab fully configured"
	exit 0
}

case $1 in
	start|-s|--start)
		start_lab
		;;
	start-full|-sf|--start-full)
		start_lab_full
		;;
	stop|-stop|--stop)
		stop_lab
		;;
	*)
		print_usage
		;;
esac
