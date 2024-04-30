# Section 2: Fundamentals, test automation, information related tasks
In this section, you will focus on different approaches to configuring your network devices.
At the end of this section, you will have learned about the three main approaches to applying configuration changes to devices, using Ansible.

## Overview
This is what we will learn about in this first section of the workshop.

```
2.1: Building a new containerlab environment
2.2: Reviewing the desired configuration state
2.3: Using specific modules to configure devices
2.4: Using config modules to configure devices
2.5: Using templates to configure devices
```
## 2.1 Building a new containerlab environment
Before we get started with configuring our switches, we need to build a new containerlab environment. This time, it will include some more switches in a traditional leaf-spine setup. As such:

![lab2 setup][lab2-overview.png]

This means you will need to create a new containerlab topology file, which creates a setup with the spine switches in place as well.

:boom: Create a new containerlab topology file, which reflects above setup. Also, more specifically:

:boom: Create a simple containerlab definition, which spins up two Arista cEOS switches which are connected to each other, as follows:
* Save your work in the containerlab directory and name the file lab1.yml.
* kinds: should be ceos and image needs to be set to: localhost/ceos:4.32.0F
* Call your nodes: leaf1, leaf2, spine1, spine2
* The leaf switches should be connected to each other via ports eth9 on and eth10 (leaf1:eth9 to leaf2:eth9 and leaf1:eth10 to leaf2:eth10).
* The leaf switches should be connected to the spine switches as such: leaf1:eth11 to spine1:eth1, leaf1:eth12 to spine2:eth1. AND leaf2:eth11 to spine1:eth2 and leaf2:eth12 to spine2:eth2.
* startup-config should be ~/advanced-networking-workshop/containerlab/configs/leaf1-start.cfg for leaf1 and leaf2-start.cfg for leaf2.
* startup-config should be ~/advanced-networking-workshop/containerlab/configs/spine1-start.cfg for spine1 and spine2-start.cfg for spine2.

<details>
<summary>Show example solution</summary>
<p>
  
```
name: lab2
topology:
  kinds:
    ceos:
      image: localhost/ceos:4.32.0F
  nodes:
    leaf1:
      kind: ceos
      startup-config: ~/advanced-networking-workshop/containerlab/configs/leaf1-start.cfg
    leaf2:
      kind: ceos
      startup-config: ~/advanced-networking-workshop/containerlab/configs/leaf2-start.cfg
    spine1:
      kind: ceos
      startup-config: ~/advanced-networking-workshop/containerlab/configs/spine1-full.cfg
    spine2:
      kind: ceos
      startup-config: ~/advanced-networking-workshop/containerlab/configs/spine2-full.cfg
  links:
    - endpoints: ["leaf1:eth9", "leaf2:eth9"]
    - endpoints: ["leaf1:eth10", "leaf2:eth10"]
    - endpoints: ["leaf1:eth11", "spine1:eth1"]
    - endpoints: ["leaf1:eth12", "spine2:eth1"]
    - endpoints: ["leaf2:eth11", "spine1:eth2"]
    - endpoints: ["leaf2:eth12", "spine2:eth2"]
```
</p>
</details>

:boom: Now it's time to rebuild the lab environment to our new setup. Use the "sudo containerlab" command like you did before, but add a --reconfigure flag at the end.

<details>
<summary>Show example solution</summary>
<p>

```
$ cd $LABDIR/containerlab
$ sudo containerlab --runtime podman deploy -t lab2.yml --reconfigure
INFO[0000] Containerlab v0.54.2 started                 
INFO[0000] Parsing & checking topology file: lab2.yml   
INFO[0000] Destroying lab: lab2                         
INFO[0011] Removing containerlab host entries from /etc/hosts file 
INFO[0011] Removing ssh config for containerlab nodes   
INFO[0011] Removing /home/mglantz/advanced-networking-workshop/containerlab/clab-lab2 directory... 
INFO[0011] Creating lab directory: /home/mglantz/advanced-networking-workshop/containerlab/clab-lab2 
INFO[0011] Running postdeploy actions for Arista cEOS 'leaf1' node 
INFO[0012] Created link: leaf1:eth9 <--> leaf2:eth9     
INFO[0012] Created link: leaf1:eth11 <--> spine1:eth1   
INFO[0012] Created link: leaf1:eth10 <--> leaf2:eth10   
INFO[0012] Created link: leaf1:eth12 <--> spine2:eth1   
INFO[0012] Running postdeploy actions for Arista cEOS 'spine1' node 
INFO[0012] Running postdeploy actions for Arista cEOS 'spine2' node 
INFO[0012] Created link: leaf2:eth11 <--> spine1:eth2   
INFO[0012] Created link: leaf2:eth12 <--> spine2:eth2   
INFO[0012] Running postdeploy actions for Arista cEOS 'leaf2' node 
INFO[0032] Adding containerlab host entries to /etc/hosts file 
INFO[0032] Adding ssh config for containerlab nodes     
+---+------------------+--------------+------------------------+------+---------+------------------+-----------------------+
| # |       Name       | Container ID |         Image          | Kind |  State  |   IPv4 Address   |     IPv6 Address      |
+---+------------------+--------------+------------------------+------+---------+------------------+-----------------------+
| 1 | clab-lab2-leaf1  | c43beb6f5075 | localhost/ceos:4.32.0F | ceos | running | 172.20.20.156/24 | 2001:172:20:20::9c/64 |
| 2 | clab-lab2-leaf2  | a6d369a8cb7a | localhost/ceos:4.32.0F | ceos | running | 172.20.20.157/24 | 2001:172:20:20::9d/64 |
| 3 | clab-lab2-spine1 | 9aac98d43532 | localhost/ceos:4.32.0F | ceos | running | 172.20.20.158/24 | 2001:172:20:20::9e/64 |
| 4 | clab-lab2-spine2 | b029cb180307 | localhost/ceos:4.32.0F | ceos | running | 172.20.20.159/24 | 2001:172:20:20::9f/64 |
+---+------------------+--------------+------------------------+------+---------+------------------+-----------------------+
```
</p>
</details>

Now that we have a new lab environment, we need to re-generateour Ansible inventory as well.

:boom: Run below command to generate a new Ansible inventory and accept SSH keys for your systems.
```
$ cd $LABDIR
$ scripts/ansible_hosts.sh lab2
```

:boom: Validate that the inventory was generated corrected using the cat command.
```
$ cd $LABDIR 
$ cat inventory
```
<details>
<summary>Show example output</summary>
<p>

```
$ cd $LABDIR
$ cat inventory 
[all:vars]
# common variables
ansible_user=admin
ansible_ssh_private_key_file=~/.ssh/advanced-networking-workshop_id_rsa
ansible_network_os=arista.eos.eos
ansible_connection=ansible.netcommon.network_cli

[leafs]
clab-lab2-leaf1 ansible_host=172.20.20.153
clab-lab2-leaf2 ansible_host=172.20.20.155

[spines]
clab-lab2-spine1 ansible_host=172.20.20.152
clab-lab2-spine2 ansible_host=172.20.20.154

[switches:children]
leafs
spines
```
</p>
</details>

Well done, now we are ready to do some configuration of our switches.

## 2.2 Reviewing the initial desired configuration state
First off, as we learn the different main approaches to doing configuration management, we will keep the desired configuration state simple.
Don't worry, once you have learned these basics, you will get to work with more production like environments.

![lab2 config state](lab2-config.png)

Above we can see what switch configuration we will start working with. It represents a commonality in most networks, which is that some configuration is static across devices and some varies across devices. In our example, the VLAN configuration is the same across our two leaf switches, while the Ethernet interface configuration is differs more between the two. As we review different approaches to applying configuration, you will find that some methods works better for different types of configuration (static vs unique).

Another thing which affects the viability of different approaches is scale. If you are managing a smaller network with just a couple of handful of devices, most approaches will work. But when you are managing larger networks, selecting the right approach will decide your level of success outright. With this in mind, consider what the future will look like. Are there plans for new network architectures? How many devices do you expect to manage next year? In five years time?

Let's get going with evaluating the different methods which you can use in the current environment.

## 2.3 Using specific modules to configure devices
This part is about learning about different module states (and managing some VLAN configuration along the way).

To configure VLANs for our switches we have some different approaches we can use.
Except for simply loading the switch with a full set of configuration, we can use a VLAN specific Ansible module to accomplish this.

For our workshop, we use Arista devices and the module is then called [eos.eos_vlans](https://docs.ansible.com/ansible/latest/collections/arista/eos/eos_vlans_module.html).

To use this module, we need to learn a bit more how it works. The module mainly has a number of states, which governs how the configuration we define will be dealt with on our device. You will find that the different states available for the eos_vlan module is also found in many other modules, so pay extra attention here, even if you do not mean to manage VLANs using Ansible.

### 1.1.4.1: eos_vlan state: "merged" ← (default)
Above option will merge the attributes we define with the existing device configuration, this means existing configuration which is not defined, will be left as is.
This option is default and will be the one selected if you do not define one.

Let's look at how this works. Below we'll list how the switch configuration looks before we have run the Ansible automation, and how it looks afterwards.

Before we run our Ansible automation the device looks like this:
```
veos(config-vlan-20)#show running-config | section vlan
vlan 10
   name ten
!
vlan 20
   name twenty
```

Next we have some Ansible automation which defines that the state of VLAN 20, should be set to suspend. Here, we also define the Ansible module state of merged.
```
- name: Merge given VLAN attributes with device configuration
  arista.eos.eos_vlans:
    config:
      - vlan_id: 20
        state: suspend
    state: merged
```

After we have run this Ansible automation, the state of the devices will then be as follows:
```
veos(config-vlan-20)#show running-config | section vlan
vlan 10
   name ten
!
vlan 20
   name twenty
   state suspend
```

Here, we can see that the name "twenty" of vlan 20, has been kept as is, as we did not define that.

### 1.1.4.2: eos_vlan state: "replaced"
Next, we can choose replaced. Replaced will force overwrite existing configuration for the VLANs we define, but leave the VLANs we do not define untouched.

Before we run our Ansible automation the device looks like this:
```
veos(config-vlan-20)#show running-config | section vlan
vlan 10
   name ten
!
vlan 20
   name twenty
```

Now, if we run below Ansible automation, which configures VLAN 20, but nothing else, and which applies the eos_vlan state of replaced, as follows:
```
- name: Merge given VLAN attributes with device configuration
  arista.eos.eos_vlans:
    config:
      - vlan_id: 20
        state: suspend
    state: replaced
```

After we have run this Ansible automation, the state of the devices will then be as follows:
```
veos(config-vlan-20)#show running-config | section vlan
vlan 10
   name ten
!
vlan 20
   state suspend
```

Please note how ```name twenty``` now is gone, as we did not define that for VLAN 20, in our Ansible automation.
At the same time, VLAN 10 is untouched, as we did not define anything for that.

### 1.1.4.3: eos_vlan state: "overridden"
This options overrides the device configuration of all VLANs you define, with whatever configuration you define. It means that if you have not defined something in your Ansible automation, it will be deleted from the device.

Before we do anything, the device looks like this:
```
veos(config-vlan-20)#show running-config | section vlan
vlan 10
   name ten
!
vlan 20
   name twenty
```

Then, we'll run below Ansible automation, which configures a single VLAN on our device:
```
- name: Override device configuration of all VLANs with provided configuration
  arista.eos.eos_vlans:
    config:
      - vlan_id: 20
        state: suspend
    state: overridden
```

After above Ansible automation has run, the device will then look like this:
```
veos(config-vlan-20)#show running-config | section vlan
vlan 20
   state suspend
```

Above we can see that that both VLAN 10 and the name definition for VLAN 20 is gone. This is because they were not defined.
Using ```overridden``` is clearly very powerful, as we will only end up with that is defined, but it's also easier to make misstakes, if we are for example generating this Ansible automation somehow and that automation suffers a failure, failing to define all VLANs we need.

### 1.1.4.4: eos_vlan state: "deleted"
This option is self explainatory, it will remove a defined VLAN. As an example:

```
- name: Delete attributes of the given VLANs.
  arista.eos.eos_vlans:
    config:
      - vlan_id: 20
    state: deleted
```

Above configuration will delete VLAN 20 out of the device (but leave any other VLANs untouched).

### 1.1.4.5: eos_vlan state: "gathered"
This option is to gather VLAN related configuration from a device, allowing you to process the information is a programtic fashion.
This is an alternativt to plainly using eos_facts to gather the vlan subset, or running and parsing ```show vlan brief``` or somethig simliar.

As an example, if with below Ansible automation:
```
- name: Gather vlans facts from the device
  arista.eos.eos_vlans:
    state: gathered
```

You get below data gathered:
```
- vlan_id: 10
  name: ten
- vlan_id: 20
  state: suspend
```

### 1.1.4.6: eos_vlan state: "rendered" / "parsed"
The rendered option allows you to convert structured data, that you would fetch from facts gathering, to native device config.
The "parsed" option allows you to do vice-versa. Meaning, to convert native device config, to structured data.
Doing this is useful when you are using Ansible to document your network.

So, "rendered" converts:

```
- vlan_id: 10
  name: ten
- vlan_id: 20
  state: suspend
```

To:
```
vlan 10
   name ten
!
vlan 20
   name twenty
   state suspend
```

And "parsed" works in the opposite way.

## 1.1.5 
# 1.2. Create MLAG VLAN and place it in a trunk group

Now that that we are fully briefed on how we can configure the VLANs on our switches, we're ready to start setting up our network.
Configure the two initial leaf switches as follows, using the eos_vlan module and other required modules which you find in the arista.eos collection, which you find here: https://docs.ansible.com/ansible/latest/collections/arista/eos/index.html. Such as:
* arista.eos.eos_vlans
* arista.eos.eos_interfaces
* arista.eos.eos_l3_interfaces
* arista.eos.eos_lag_interfaces
* arista.eos.eos_config

* Target state: leaf1
```
vlan 4090
   name mlag-peer
   trunk group mlag-peer
!
interface Vlan4090
   no autostate
   ip address 10.0.199.254/31
   no shut
!
interface Ethernet9
   description mlag peer link
   channel-group 999 mode active
!
interface Ethernet10
   description mlag peer link
   channel-group 999 mode active
!
interface Port-Channel999
   description MLAG Peer
   switchport mode trunk
   switchport trunk group mlag-peer
   spanning-tree link-type point-to-point
!
exit
 no spanning-tree vlan 4090
!
ip routing
!
mlag configuration					      
   domain-id leafs					      
   local-interface Vlan4090				      
   peer-address 10.0.199.255				      
   peer-link Port-Channel999				      
   no shut
!
ip virtual-router mac-address c0:01:ca:fe:ba:be
!
exit
```

* Target state: leaf2
```
vlan 4090
   name mlag-peer
   trunk group mlag-peer
!
interface Vlan4090
   no autostate
   ip address 10.0.199.255/31
!
interface Ethernet9
   description mlag peer link
   channel-group 999 mode active
!
interface Ethernet10
   description mlag peer link
   channel-group 999 mode active
!
exit
 no spanning-tree vlan 4090
!
!
ip routing
!
mlag configuration
   domain-id leafs
   local-interface Vlan4090
   peer-address 10.0.199.254
   peer-link Port-Channel999
!
ip virtual-router mac-address c0:01:ca:fe:ba:be
!
exit
```






