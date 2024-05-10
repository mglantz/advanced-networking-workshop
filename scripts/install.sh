#!/bin/bash
# Installation script for workshop, meant to be run by cloud init or such
# Magnus Glantz, sudo@redhat.com, 2024

# Install and enable podman
sudo dnf install podman podman-docker
sudo systemctl enable podman --now

# Install containerlab and configure SELinux so it works
sudo bash -c "$(curl -sL https://get.containerlab.dev)"
sudo semanage fcontext -a -t textrel_shlib_t $(which containerlab)
sudo restorecon $(which containerlab)

cd ~
git clone https://github.com/mglantz/advanced-networking-workshop

cp advanced-networking-workshop/scripts/id_rsa ~/.ssh/advanced-networking-workshop
chmod 600 ~/.ssh/advanced-networking-workshop
ssh-add ~/.ssh/advanced-networking-workshop

echo "export LABDIR=~/advanced-networking-workshop" >>~/.bashrc

