#!/bin/bash
# Installation script for workshop, meant to be run by cloud init or such
# Magnus Glantz, sudo@redhat.com, 2024

# Install and enable podman
sudo dnf install podman podman-docker git python3-pip curl
sudo systemctl enable podman --now

# Install containerlab and configure SELinux so it works
sudo bash -c "$(curl -sL https://get.containerlab.dev)"
sudo semanage fcontext -a -t textrel_shlib_t $(which containerlab)
sudo restorecon $(which containerlab)

cd ~
git clone https://github.com/mglantz/advanced-networking-workshop

cp advanced-networking-workshop/scripts/id_rsa ~/.ssh/advanced-networking-workshop
chmod 600 ~/.ssh/advanced-networking-workshop
eval $(ssh-agent -s)
ssh-add ~/.ssh/advanced-networking-workshop

echo "export LABDIR=~/advanced-networking-workshop" >>~/.bashrc
export LABDIR=~/advanced-networking-workshop

echo 'eval $(ssh-agent -s)' >>~/.bashrc

read -p "Transfer cEOS image file to home directory. Press enter when done." donenow

sudo podman import ~/cEOS64-lab-4.32.0F.tar.tar ceos:4.32.0F


