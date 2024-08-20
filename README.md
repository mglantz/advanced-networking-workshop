# advanced-networking-workshop
Hello and welcome to this more advanced Ansible workshop on the topic of network automation.

Scroll down past the overview if you want information about how to install this workshop.

:boom: If you are a person who are performing this workshop, click on the link of Section 0: Instroduction to the lab.

:exclamation: If you find any issues, please consider to contribute a fix.

## Overview of lab excercises
### [Section 0: Introduction to the lab](labs/lab-0/README.md)
```
0.1: Introduction to the workshop
0.2: Technical prerequisites
0.3: Knowledge prerequisites
0.4: What this workshop is NOT about
0.5: Lab graphics
0.6: If something goes wrong
0.7: Preparing to do the lab
0.8: Accessing the lab for the first time
```

### [Section 1: Fundamentals, test automation, information related tasks](labs/lab-1/README.md)
```
1.1: Different Ansible approaches to automating network devices
1.1.1: Vendor differences
1.1.2: Network test automation (using ContainerLab)
1.1.2.1: Creating a containerlab test environment
1.1.3: Gathering information
1.1.3.1: Using the command module
1.1.3.2: Performing backups
1.1.3.3: Documenting your network
1.1.3.4: Adding intelligence to your playbooks
1.1.3.5: Operational use-cases
```

### [Section 2: Applying configuration to devices](labs/lab-2/README.md)
```
2.1: Building a new containerlab environment
2.2: Reviewing the initial desired configuration state
2.3: Using the command module to accomplish our desired state
2.3.1: Assessing the use of the command module
2.4: Learning Network Resource modules
2.4.1: module state: "merged" (often the default)
2.4.2: module state: "replaced"
2.4.3: module state: "overridden"
2.4.4: module state: "deleted"
2.4.5: module state: "gathered"
2.4.6: module state: "rendered" and "parsed"
2.5: Reset your lab environment
2.6: Using network resource modules to archieve the desired configuration state
2.6.1: Assessing the use of purpose specific configuration modules
2.7: Using config modules to make changes
2.7.1: Using the config module to load static config files into devices
2.7.2: Using the config module to inject lines of config into devices
2.7.3: Using the config module to load dynamic config files into devices
```

### [Section 3: Applying best practices to build a BGP EVPN architecture](labs/lab-3/README.md)
```
3.1 Review of containerlab and desired state device configuration
3.2 Automating your network
3.3. Validating your setup
```

# Installation of lab infrastructure

:exclamation: Below instructions are only for people who need to install the lab environment themselves, not for people who are students in a pre-setup workshop.
:exclamation: The playbooks in the provision directory are for setting this workshop up at scale on AWS and may have to be adjusted if you are to use them. Below instructions allows you to setup this workshop on a local system, without a VScode instance.

To get the containerlab setup working on Fedora 39 or Red Hat Enterprise Linux 9.4, using podman:
1. Install podman
```
$ sudo dnf install podman podman-docker git ansible
```

2. Start podman services:
```
$ sudo systemctl enable podman --now
```

3. Install containerlab and configure it to work with SELinux
```
$ sudo bash -c "$(curl -sL https://get.containerlab.dev)"
$ sudo semanage fcontext -a -t textrel_shlib_t $(which containerlab)
$ sudo restorecon $(which containerlab)
```

4. Download the cEOS 4.32.0F container image from Arista

5. Do a podman import on this image (yeah, needs to be done as root, as containerlab requires things to be run as root).
```
$ sudo podman import cEOS64-lab-4.32.0F.tar.tar ceos:4.32.0F 
```

6. Clone this repository into your /home/user directory
```
cd ~
git clone https://github.com/mglantz/advanced-networking-workshop
```

7. Configure environment
```
$ export LABDIR="$HOME/advanced-networking-workshop"
$ eval $(ssh-agent -s)
$ cp $LABDIR/scripts/id_rsa ~/.ssh/adv-networking
$ chmod 600 ~/.ssh/adv-networking
$ ssh-add ~/.ssh/adv-networking
```

8. Do a test start of a containerlab
```
cd $LABDIR/containerlab
sudo containerlab --runtime podman deploy -t solutions/lab1.yml
```

9. Validate setup by accessing the switches.
```
ssh admin@IPv4-address-of-switch
# User/password is: admin/admin but you should be automatically logged in via your ssh key.
```

10. Now you are ready to start the lab. [Goto lab-0/README.md](labs/lab-0/README.md).



