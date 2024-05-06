# advanced-networking-workshop
Work in progress, everything is a draft.

## Overview of lab excercises
### [Section 0: Introduction to the lab](labs/lab-0/README.md)
```
0.1: Introduction to the workshop
0.2: Knowledge prerequisites
0.3: What this workshop is NOT about
0.4: Lab graphics
0.5: If something goes wrong
0.6: Preparing to do the lab
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
2.2: Reviewing the desired configuration state
2.3: Using specific modules to configure devices
2.4: Using config modules to configure devices
2.5: Using templates to configure devices
```

### Section 3: Applying best practices to build a BGP EVPN architecture?
```
1. Configure Multi-Chassis Link Aggregation (MLAG)
2. Configure MLAG – Dual-Active Detection (aka Peer Keepalive)
3. Configure Underlay Point-to-Point Interfaces
4. Configure Underlay Point-to-Point Interfaces - Leaf-to-Leaf
5. Configure Loopbacks for BGP Peering
6. Configure BGP Process
7. Configure Underlay EBGP Neighbors
8. Configure Underlay IBGP Neighbors
9. Activating BGP
10. Enable EVPN Capability
11. Configure BGP EVPN Overlays - Leaf-to-Spine
12. Configure BGP EVPN Overlay - Spines-to-Leafs
13. Validating EVPN Neighbors
14. Configure VXLAN Tunnel Endpoints (VTEP)
15. Validating host to host communication
16. Future: Transporting L2VXLAN with EVPN
17. Future: Transporting L3VXLAN with EVPN 
```

# Installation of lab infrastructure

To get the containerlab setup working on Fedora 39, using podman.
1. Install podman
```
$ sudo dnf install podman podman-docker
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

6. Clone this repository into your /home/user directory. If you place it elsewhere, adjust items as described in 7.
```
git clone https://github.com/mglantz/advanced-networking-workshop
```

7. Go into the directory and ensure the path for startup-config for each node is correct.
```
cd advanced-networking-workshop/containerlab
vim ceos-evpn-overlaid.clab-full.yml
```

8. Startup the containerlab infrastructure
```
$ sudo containerlab --runtime podman deploy -t ceos-evpn-overlaid.clab-full.yml
INFO[0000] Containerlab v0.54.2 started                 
INFO[0000] Parsing & checking topology file: ceos-evpn-overlaid.clab-full.yml 
INFO[0000] Creating lab directory: /home/mglantz/advanced-networking-workshop/containerlab/clab-EVPN-Overlaid 
INFO[0001] Created link: leaf8:eth7 <--> host4:eth3     
INFO[0001] Created link: leaf8:eth8 <--> host4:eth4     
INFO[0001] Running postdeploy actions for Arista cEOS 'leaf8' node 
INFO[0002] Created link: leaf5:eth7 <--> host3:eth1     
INFO[0002] Created link: leaf2:eth7 <--> host1:eth3     
INFO[0002] Created link: leaf1:eth7 <--> host1:eth1     
INFO[0002] Created link: leaf6:eth7 <--> host3:eth3     
INFO[0002] Created link: leaf4:eth7 <--> host2:eth3     
INFO[0002] Created link: leaf7:eth7 <--> host4:eth1     
INFO[0002] Created link: leaf3:eth7 <--> host2:eth1     
INFO[0002] Created link: leaf5:eth8 <--> host3:eth2     
INFO[0002] Created link: leaf7:eth8 <--> host4:eth2     
INFO[0002] Created link: leaf3:eth8 <--> host2:eth2     
INFO[0002] Created link: leaf2:eth8 <--> host1:eth4     
INFO[0002] Created link: leaf4:eth8 <--> host2:eth4     
INFO[0002] Created link: leaf6:eth8 <--> host3:eth4     
INFO[0002] Created link: leaf1:eth8 <--> host1:eth2     
INFO[0002] Created link: leaf7:eth9 <--> leaf8:eth9     
INFO[0002] Created link: leaf5:eth9 <--> leaf6:eth9     
INFO[0002] Created link: leaf3:eth9 <--> leaf4:eth9     
INFO[0003] Created link: leaf7:eth10 <--> leaf8:eth10   
INFO[0003] Created link: leaf3:eth11 <--> spine1:eth3   
INFO[0003] Created link: leaf1:eth9 <--> leaf2:eth9     
INFO[0003] Created link: leaf3:eth10 <--> leaf4:eth10   
INFO[0003] Created link: leaf5:eth10 <--> leaf6:eth10   
INFO[0003] Created link: leaf3:eth12 <--> spine2:eth3   
INFO[0003] Running postdeploy actions for Arista cEOS 'leaf3' node 
INFO[0003] Created link: leaf4:eth11 <--> spine1:eth4   
INFO[0003] Created link: leaf5:eth11 <--> spine1:eth5   
INFO[0003] Created link: leaf2:eth11 <--> spine1:eth2   
INFO[0003] Created link: leaf1:eth10 <--> leaf2:eth10   
INFO[0003] Running postdeploy actions for Arista cEOS 'leaf7' node 
INFO[0003] Created link: leaf4:eth12 <--> spine2:eth4   
INFO[0003] Running postdeploy actions for Arista cEOS 'leaf4' node 
INFO[0003] Created link: leaf1:eth11 <--> spine1:eth1   
INFO[0003] Created link: leaf7:eth11 <--> spine1:eth7   
INFO[0003] Created link: leaf2:eth12 <--> spine2:eth2   
INFO[0003] Running postdeploy actions for Arista cEOS 'leaf2' node 
INFO[0003] Created link: leaf5:eth12 <--> spine2:eth5   
INFO[0003] Running postdeploy actions for Arista cEOS 'leaf5' node 
INFO[0003] Created link: leaf7:eth12 <--> spine2:eth7   
INFO[0003] Created link: leaf6:eth11 <--> spine1:eth6   
INFO[0003] Created link: leaf1:eth12 <--> spine2:eth1   
INFO[0003] Created link: leaf6:eth12 <--> spine2:eth6   
INFO[0003] Running postdeploy actions for Arista cEOS 'leaf6' node 
INFO[0003] Running postdeploy actions for Arista cEOS 'leaf1' node 
INFO[0003] Created link: leaf8:eth12 <--> spine2:eth8   
INFO[0003] Running postdeploy actions for Arista cEOS 'spine2' node 
INFO[0003] Created link: leaf8:eth11 <--> spine1:eth8   
INFO[0003] Running postdeploy actions for Arista cEOS 'spine1' node 
INFO[0047] Adding containerlab host entries to /etc/hosts file 
INFO[0047] Adding ssh config for containerlab nodes     
+----+---------------------------+--------------+----------------------------------------+-------+---------+-----------------+-----------------------+
| #  |           Name            | Container ID |                 Image                  | Kind  |  State  |  IPv4 Address   |     IPv6 Address      |
+----+---------------------------+--------------+----------------------------------------+-------+---------+-----------------+-----------------------+
|  1 | clab-EVPN-Overlaid-host1  | 6a020f644d27 | ghcr.io/hellt/network-multitool:latest | linux | running | 172.20.20.18/24 | 2001:172:20:20::12/64 |
|  2 | clab-EVPN-Overlaid-host2  | 1b6aed8d2c92 | ghcr.io/hellt/network-multitool:latest | linux | running | 172.20.20.17/24 | 2001:172:20:20::11/64 |
|  3 | clab-EVPN-Overlaid-host3  | ae4844d45f43 | ghcr.io/hellt/network-multitool:latest | linux | running | 172.20.20.19/24 | 2001:172:20:20::13/64 |
|  4 | clab-EVPN-Overlaid-host4  | 3067323f9709 | ghcr.io/hellt/network-multitool:latest | linux | running | 172.20.20.20/24 | 2001:172:20:20::14/64 |
|  5 | clab-EVPN-Overlaid-leaf1  | 67e061fafd0e | localhost/ceos:4.32.0F                 | ceos  | running | 172.20.20.30/24 | 2001:172:20:20::1e/64 |
|  6 | clab-EVPN-Overlaid-leaf2  | cf5bab9c6de5 | localhost/ceos:4.32.0F                 | ceos  | running | 172.20.20.29/24 | 2001:172:20:20::1d/64 |
|  7 | clab-EVPN-Overlaid-leaf3  | 0e4b744e221a | localhost/ceos:4.32.0F                 | ceos  | running | 172.20.20.27/24 | 2001:172:20:20::1b/64 |
|  8 | clab-EVPN-Overlaid-leaf4  | 35478b26f68e | localhost/ceos:4.32.0F                 | ceos  | running | 172.20.20.26/24 | 2001:172:20:20::1a/64 |
|  9 | clab-EVPN-Overlaid-leaf5  | f54b6e0cea17 | localhost/ceos:4.32.0F                 | ceos  | running | 172.20.20.25/24 | 2001:172:20:20::19/64 |
| 10 | clab-EVPN-Overlaid-leaf6  | 42b7d1ecddf4 | localhost/ceos:4.32.0F                 | ceos  | running | 172.20.20.28/24 | 2001:172:20:20::1c/64 |
| 11 | clab-EVPN-Overlaid-leaf7  | ad9da165f66b | localhost/ceos:4.32.0F                 | ceos  | running | 172.20.20.24/24 | 2001:172:20:20::18/64 |
| 12 | clab-EVPN-Overlaid-leaf8  | 64b15d2b1893 | localhost/ceos:4.32.0F                 | ceos  | running | 172.20.20.21/24 | 2001:172:20:20::15/64 |
| 13 | clab-EVPN-Overlaid-spine1 | 4fc9645f6f7c | localhost/ceos:4.32.0F                 | ceos  | running | 172.20.20.22/24 | 2001:172:20:20::16/64 |
| 14 | clab-EVPN-Overlaid-spine2 | 1ae5145ad263 | localhost/ceos:4.32.0F                 | ceos  | running | 172.20.20.23/24 | 2001:172:20:20::17/64 |
+----+---------------------------+--------------+----------------------------------------+-------+---------+-----------------+-----------------------+
```

9. Validate setup by accessing the switches.
```
ssh admin@IPv4-address-of-switch
# User/password is: admin/admin
```

10. Connecting to a client system and validating connection to spine switch
```
$ sudo podman ps
CONTAINER ID  IMAGE                                   COMMAND               CREATED         STATUS                    PORTS       NAMES
ae4844d45f43  ghcr.io/hellt/network-multitool:latest  bash                  56 seconds ago  Up 55 seconds (starting)              clab-EVPN-Overlaid-host3
6a020f644d27  ghcr.io/hellt/network-multitool:latest  bash                  56 seconds ago  Up 55 seconds (starting)              clab-EVPN-Overlaid-host1
3067323f9709  ghcr.io/hellt/network-multitool:latest  bash                  56 seconds ago  Up 55 seconds (starting)              clab-EVPN-Overlaid-host4
1b6aed8d2c92  ghcr.io/hellt/network-multitool:latest  bash                  56 seconds ago  Up 55 seconds (starting)              clab-EVPN-Overlaid-host2
64b15d2b1893  localhost/ceos:4.32.0F                  bash -c /mnt/flas...  55 seconds ago  Up 55 seconds (starting)              clab-EVPN-Overlaid-leaf8
cf5bab9c6de5  localhost/ceos:4.32.0F                  bash -c /mnt/flas...  55 seconds ago  Up 54 seconds (starting)              clab-EVPN-Overlaid-leaf2
4fc9645f6f7c  localhost/ceos:4.32.0F                  bash -c /mnt/flas...  55 seconds ago  Up 54 seconds (starting)              clab-EVPN-Overlaid-spine1
ad9da165f66b  localhost/ceos:4.32.0F                  bash -c /mnt/flas...  55 seconds ago  Up 54 seconds (starting)              clab-EVPN-Overlaid-leaf7
f54b6e0cea17  localhost/ceos:4.32.0F                  bash -c /mnt/flas...  55 seconds ago  Up 54 seconds (starting)              clab-EVPN-Overlaid-leaf5
1ae5145ad263  localhost/ceos:4.32.0F                  bash -c /mnt/flas...  55 seconds ago  Up 54 seconds (starting)              clab-EVPN-Overlaid-spine2
35478b26f68e  localhost/ceos:4.32.0F                  bash -c /mnt/flas...  55 seconds ago  Up 54 seconds (starting)              clab-EVPN-Overlaid-leaf4
0e4b744e221a  localhost/ceos:4.32.0F                  bash -c /mnt/flas...  55 seconds ago  Up 54 seconds (starting)              clab-EVPN-Overlaid-leaf3
42b7d1ecddf4  localhost/ceos:4.32.0F                  bash -c /mnt/flas...  55 seconds ago  Up 54 seconds (starting)              clab-EVPN-Overlaid-leaf6
67e061fafd0e  localhost/ceos:4.32.0F                  bash -c /mnt/flas...  55 seconds ago  Up 54 seconds (starting)              clab-EVPN-Overlaid-leaf1

$ sudo podman exec -it clab-EVPN-Overlaid-host1 /bin/bash
bash-5.0# ping -c3 172.20.20.22
PING 172.20.20.22 (172.20.20.22) 56(84) bytes of data.
64 bytes from 172.20.20.22: icmp_seq=1 ttl=64 time=0.040 ms
64 bytes from 172.20.20.22: icmp_seq=2 ttl=64 time=0.036 ms
64 bytes from 172.20.20.22: icmp_seq=3 ttl=64 time=0.057 ms

--- 172.20.20.22 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2056ms
rtt min/avg/max/mdev = 0.036/0.044/0.057/0.009 ms
bash-5.0#
```

11. Now you are ready to start the lab. Goto lab-0/README.md.



