# 2: Section 2: Ansible networking fundamentals
In this section, you will learn about some of the different main approaches when automating against network devices.
At the end of this section, you will have automatically learned different ways you can configure VLAN and interface information.
This is before we go unto more advanced networking architectures, commonly found in larger data centers.

## Overview

This is what we will learn about in this section of the workshop.

2.1: Different Ansible approaches to automating network devices
2.1.1 Network test automation (using ContainerLab)
2.1.1.1 Creating a containerlab test environment
2.1.2 Gathering facts
2.1.3 Using the command module
2.1.4 Using specific modules to configure devices
2.1.5 Using config modules to configure devices
2.1.6 Using templates

## 2.1: Different Ansible approaches to automating network devices
Ansible is versatile, meaning you can approach automating your network in many different ways, with that said, there are some fundamental likeness which you will find, also across different network vendors which we will deal with in this part of the workshop. Except for there being some general approaches which applies to your actual automation of network devices, the development approach is very much similiar, no matter what vendor you may be using.

:thumbsup: But before we start, we would like to remind you of Ansible's three guiding principles:
* Complexity kills productivity (keep it simple, it makes it robust, scalable and easy to maintain)
* Optimize for readability (makes for easier collaboration, maintenance and makes it more robust)
* Think declaratively (Ansible is a state engine, do not try to 'code' with playbooks)

## 2.1.1 Network test automation (using ContainerLab)
Writing Ansible automation may not feel like programming, but make no misstake, that is what you are doing. A fundamental of programming is testing your code.
The basics of testing your Ansible code includes static code analysis using standard Ansible tools such as ansible-lint, yamllint, ansible-test or molecule.
You can read more about this on the [ansible.com dev-guide for testing](https://docs.ansible.com/ansible/latest/dev_guide/testing.html).

When thing becomes specific for networking, is when we are doing more proper integration tests, where we test to see if the Ansible automation actually does what it's supposed to do. In the world of normal operating systems, this is normally done by spinning up test VMs or containers and testing if your playbooks works against those. But in the world of networking, things are not as far ahead yet and it's not common that people use virtualized or containerized test environments for router or switch related configuration changes.

With this said, allow us to introduce, [containerlab](https://containerlab.dev), which is a tool which allows you to spin up container based working environments, using a CLI. [Containerlab is also open source, distributed with a BSD license](https://github.com/srl-labs/containerlab/).

In order for you to be able to create an CI/CD flow, where newly created network automation is automatically tested and pushed to your environments, you will need to resolve automated testing. Of course, in order to be 100% certain of what a change does, you will need an actual physical test environment to test switch or routing related configuration. But as that is still fairly rare, starting with a containerized test environment goes faster and requires little budget for upfront purcheses of equipment, as containerlab can run on a normal virtual machine.

![Overview of test workflow](ansible_working_testing.png)

Quoting from the containerlab webpage, the more specifically state:
```
Containerlab focuses on the containerized Network Operating Systems,
which are typically used to test network features and designs, such as:

    Nokia SR Linux
    Arista cEOS
    Cisco XRd
    Azure SONiC
    Juniper cRPD
    Cumulus VX
    Keysight IXIA-C
    RARE/freeRtr

In addition to native containerized NOSes, containerlab can launch traditional virtual machine 
based routers using vrnetlab or boxen integration
```

:boom: If you can. [Click here, to have a look at this introductionary video on YouTube, for containerlab](https://www.youtube.com/watch?v=xdi7rwdJgkg).

## 2.1.1.1 Creating a containerlab environment
In this section, you will learn how to create your first containerlab environment, which we will use to test against.

:boom: Go to your advanced-networking-workshop/containerlab directory.
```
$ cd advanced-networking-workshop/containerlab
```

:boom: Create a simple containerlab definition, which spins up two Arista cEOS switches which are connected to each other. As follows:
* Save your work in the containerlab directory and name the file lab1.yml.
* kinds: should be ceos and image needs to be set to: localhost/ceos:4.32.0F
* Call your nodes leaf1 and leaf2
* The switches should be connected to each other via ports eth9 on and eth10 (leaf1:eth9 to leaf2:eth9 and leaf1:eth10 to leaf2:eth10).
* startup-config should be ~/advanced-networking-workshop/containerlab/configs/leaf1-start.cfg for leaf1 and leaf2-start.cfg for leaf2.

<details>
<summary>Show example solution</summary>
<p>
  
```
name: lab1
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
  links:
    - endpoints: ["leaf1:eth9", "leaf2:eth9"]
    - endpoints: ["leaf1:eth10", "leaf2:eth10"]
```
</p>
</details>

:boom: Now, let's review the configuration used to start up our switches. Run the "cat" command on your leaf1/2.cfg files to view them.

<details>
<summary>Show example solution</summary>
<p>

```
$ cd $LABDIR
$ cat containerlab/config/leaf1-start.cfg
! device: leaf1 (cEOSLab, EOS-4.32.0F-36401836.4320F (engineering build))
!
no aaa root
!
username admin privilege 15 role network-admin secret sha512 $6$pgp7vrOg4hZb1nqq$xpnPvPleMFtnajboQ2zvrKfsQwAQZ4HkTpz1M83o/TiGxRvxvks/3mpmbea2BD8PX1PH/P70WPTvLd0OkJjzn1
username admin ssh-key ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDRVIRvlAwQ4pbwyISj9Rekpyi6hKSeYzGCmZG3Pq7/mg/cekHhgWRSqFOM13AsKzR6jiSFU73+ifQSM0g8oi3R95sFDY4QeGXastziQ3aHUio40YteE/lUADaRyBy7w2jmnu0+se3jK8wymq2MwaFbTtMeUBvMhOvuudhvG1cB/zcH0TLnadTW+Oqmu2CvNpUlpq1DIiI10XUphaHpETFfOYyIQ7STiiEd4ink3iPy8zGmzgQkeK41crz6ENeBnj8tgL4o2rMmYWlRgjj/t8e2sUDz3wEVxC2JhZDewuZ6ImJ2yNLt+8yOhc2kTu3oo4pZ2f/kdColqf/BMXOtfP5B
!
transceiver qsfp default-mode 4x10G
!
service routing protocols model multi-agent
!
hostname leaf1
!
spanning-tree mode mstp
!
system l1
   unsupported speed action error
   unsupported error-correction action error
!
management api http-commands
   no shutdown
!
management api gnmi
   transport grpc default
!
management api netconf
   transport ssh default
!
interface Ethernet7
!
interface Ethernet8
!
interface Ethernet9
!
interface Ethernet10
!
interface Ethernet11
!
interface Ethernet12
!
interface Management0
   ip address 172.20.20.2/24
   ipv6 address 2001:172:20:20::2/64
!
no ip routing
!
end
```
</p>
</details>

:exclamation: As you can see, there are a few things we need to setup for us to use the devices for testing, namely:
* A configured management interface which we can connect to
* An initial user which we can connect with
* Means to authenticate with our user (in this case, both a password and a SSH key is configured).

If you SSH to a device in your setup, you will authenticate automatically, that is because the SSH key has been added in your environment.

:boom: Next, you are to start your lab environment, using the "sudo containerlab" CLI command, accordingly:
* Use --runtime podman
* If you have already tried to deploy the lab once, add the --reconfigure parameter.
* Run "sudo containerlab --help" to get more information.

<details>
<summary>Show example solution</summary>
<p>

```
$ sudo containerlab --runtime podman deploy -t lab1.yml --reconfigure
INFO[0000] Containerlab v0.54.2 started                 
INFO[0000] Parsing & checking topology file: containerlab-basic.yml 
INFO[0000] Removing /home/mglantz/advanced-networking-workshop/containerlab/clab-lab1 directory... 
INFO[0000] Creating lab directory: /home/mglantz/advanced-networking-workshop/containerlab/clab-lab1 
INFO[0000] Running postdeploy actions for Arista cEOS 'leaf1' node 
INFO[0000] Created link: leaf1:eth9 <--> leaf2:eth9     
INFO[0000] Created link: leaf1:eth10 <--> leaf2:eth10   
INFO[0000] Running postdeploy actions for Arista cEOS 'leaf2' node 
INFO[0018] Adding containerlab host entries to /etc/hosts file 
INFO[0018] Adding ssh config for containerlab nodes     
+---+-------------------------------+--------------+------------------------+------+---------+------------------+-----------------------+
| # |             Name              | Container ID |         Image          | Kind |  State  |   IPv4 Address   |     IPv6 Address      |
+---+-------------------------------+--------------+------------------------+------+---------+------------------+-----------------------+
| 1 | clab-containerlab-basic-leaf1 | 0bc156845e92 | localhost/ceos:4.32.0F | ceos | running | 172.20.20.144/24 | 2001:172:20:20::90/64 |
| 2 | clab-containerlab-basic-leaf2 | 684d465b58a4 | localhost/ceos:4.32.0F | ceos | running | 172.20.20.145/24 | 2001:172:20:20::91/64 |
+---+-------------------------------+--------------+------------------------+------+---------+------------------+-----------------------+
```
</p>
</details>

:boom: Run the "scripts/ansibe_hosts.sh basic" command to generate a properly configured Ansible inventory ($LABDIR/inventory) and accept SSH fingerprints
```
$ ../scripts/ansible_hosts.sh basic
```
Please note that a successful run of the command does not generate any output. 

:boom: Validate that your have a correctly configured inventory file.
```
$ cd $LABDIR
$ cat inventory
```

<details>
<summary>Show example inventory file</summary>
<p>

```
[all:vars]
# common variables
ansible_user=admin
ansible_ssh_private_key_file=~/.ssh/advanced-networking-workshop_id_rsa
ansible_network_os=arista.eos.eos
ansible_connection=ansible.netcommon.network_cli

[leafs]
clab-containerlab-basic-leaf1 ansible_host=172.20.20.144
clab-containerlab-basic-leaf2 ansible_host=172.20.20.145
```

Please note that IP addresses in your inventory file likely will differ.

</p>
</details>

:boom: Next, SSH to your switches using the admin user and validate ports Ethernet9 and 10 are connected.

<details>
<summary>Show solution</summary>
<p>

```
# Take the IP addresses from your inventory file
$ ssh admin@172.20.20.144
Last login: Mon Apr 29 20:46:22 2024 from 172.20.20.1
leaf1>sh int stat
Port       Name   Status       Vlan     Duplex Speed  Type            Flags Encapsulation
Et9               connected    1        full   1G     EbraTestPhyPort                   
Et10              connected    1        full   1G     EbraTestPhyPort                   
Ma0               connected    routed   a-full a-1G   10/100/1000                       

leaf1>exit
Connection to 172.20.20.144 closed.
```
</p>
</details>

:star: If you have time, you can also validate that the overall running configuration is correct.

:boom: Next create a simple playbook which you save in the advanced-networking-workshop directory, which uses the ansible.builtin.ping module to ping the switches.

<details>
<summary>Show solution</summary>

```
cat << 'EOF' >$LABDIR/ping.yml
- name: Ping leaf switches
  hosts: leafs
  tasks:
    - name: Validate that we have a working connection to each switch
      ansible.builtin.ping:
        data: pong
EOF
```
</p>
</details>

:boom: Next, run a static code analysis on your playbook, using the "ansible-lint" command.

<details>
<summary>Show solution</summary>

```
$ ansible-lint ping.yml 

Passed: 0 failure(s), 0 warning(s) on 1 files. Last profile that met the validation criteria was 'production'.
```
</p>
</details>

:exclamation: If you had 0 failures and 0 warnings, you can go on to the next task, otherwise, fix your issues.

:boom: Next, run the basic playbook stored in $LABDIR/ping.yml against our new switches.

<details>
<summary>Show solution</summary>
<p>

```
$ cd $LABDIR
$ ansible-playbook -i inventory $LABDIR/ping.yml

PLAY [Ping leaf switches] ***********************************************************************************************************************************************************

TASK [Gathering Facts] **************************************************************************************************************************************************************
[WARNING]: ansible-pylibssh not installed, falling back to paramiko
ok: [clab-containerlab-basic-leaf2]
ok: [clab-containerlab-basic-leaf1]

TASK [Validate that we have a working connection to each switch] ********************************************************************************************************************
ok: [clab-containerlab-basic-leaf1]
ok: [clab-containerlab-basic-leaf2]

PLAY RECAP **************************************************************************************************************************************************************************
clab-containerlab-basic-leaf1 : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
clab-containerlab-basic-leaf2 : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```
</p>
</details>

Well done! You successfully executed most parts of what we would expected to see in an automated CI/CD pipeline, meaning:
* Creation of an Ansible playbook
* Run static code analysis on Ansible playbook
* Create test environment
* Run playbook against test environment

:star: If you like, you can deploy your environment and do the test over again.
<details>
<summary>Show solution</summary>
<p>

Don't forget to add --reconfigure to your "sudo containerlab" command and re-run the "scripts/ansible_host.sh basic" command doing so.
</p>
</details>

The only thing we have not covered here, is how you would execute the tasks automatically in a CI/CD pipeline, the reason for that is that it would differ depending on what CI engines you run. With that said, most CI engines supports shell scripting, meaning you almost only have to add the commands you leared about here, to automate the process.

## 2.1.2 Gathering information about your devices
Next thing which is something you often do when you automate against network elements, is gathering facts and information. Collecting information about devices are key to three main Ansible network use-cases:

* Performing backups
* Documenting the network
* Operational use-cases
* Adding intelligence to your playbooks

:exclamation: What's special to facts gathering for network devices is that most vendors has their own facts gathering modules. For example:
* [Cisco IOS Facts gathering](https://docs.ansible.com/ansible/latest/collections/cisco/ios/ios_facts_module.html)
* [Arista EOS Facts gathering](https://docs.ansible.com/ansible/latest/collections/arista/eos/eos_facts_module.html)
* [Juniper JunOS Facts gathering](https://docs.ansible.com/ansible/latest/collections/junipernetworks/junos/junos_facts_module.html)

Let's dive into some of the basic use-cases and how we can implement them. First off, is performing backups.

### 2.1.2.1 Performing backups
You may use the various facts gathering modules to perform a backup, but normally there is a config module you can use for this specific purpose, which is simpler to use. Again, like the fact gathering module, there are unique versions of the config modules for different network vendors. For example:

* [Cisco config module](https://docs.ansible.com/ansible/latest/collections/cisco/ios/ios_config_module.html)
* [Arista config module](https://docs.ansible.com/ansible/latest/collections/arista/eos/eos_config_module.html)
* [Juniper config module](https://docs.ansible.com/ansible/latest/collections/junipernetworks/junos/junos_config_module.html)

Now it's time to do something.

:boom: Read up on the Arista config module and create a playbook called arista_backup.yml which backups the documentation to the backups folder located in the lab home directory.

:exclamation: You will need "become: yes" for this operation.

<details>
<summary>Show solution</summary>
<p>

```
- name: "Backup Arista switches"
  hosts: leafs
  gather_facts: no
  become: yes
  tasks:
    - name: Backup switch (eos)
      arista.eos.eos_config:
        backup: yes
      register: backup_eos_location

    - name: Create backup dir
      file:
        path: "~/advanced-networking-workshop/backups/{{ inventory_hostname }}"
        state: directory
        recurse: yes

    - name: Copy backup files into backups directory
      copy:
        src: "{{ backup_eos_location.backup_path }}"
        dest: "~/advanced-networking-workshop/backups/{{ inventory_hostname }}/{{ inventory_hostname }}.cfg"
```
</p>
</details>

:boom: Now, let's review the backed up configuration, it's located in $LABDIR/backups

<details>
<summary>Show solution</summary>
<p>

```
$ cat $LABDIR/backups/clab-containerlab-basic-leaf1/clab-containerlab-basic-leaf1.cfg
...
```
</p>
</details>

Well done, creating backups does not have to be more difficult. Of course, normally you would put them somewhere special, a location also backed up by some backup software.

### 2.1.2.1 Documenting the network
We will review a more basic example of creating network documentation, where we write information about our network devices to a plain text file. With that said, this information may as well be written to your CMDB system, using the ansible.builtin.uri module (or more specific one) to do a API call to some external system.

:boom: Create a playbook called network_documentation.yml which uses the "arista.eos.eos_facts" module to gather facts from your switches, then use the copy module and jinja templating to save this content to the file network-documentation.txt. 

:exclamation: This may be a bit advanced, so there is no shame in copying the solution in true open source fashion.

<details>
<summary>Show solution</summary>
<p>

```
cat << 'EOF' >$LABDIR/network_documentation.yml
- name: "Document Arista switches"
  hosts: leafs
  gather_facts: no

  tasks:
    - name: Gather facts (eos)
      arista.eos.eos_facts:

    - name: Display some facts
      debug:
        msg: "Collecting information about {{ ansible_net_hostname }} running {{ ansible_net_system }} {{ ansible_net_version }}"

    - name: Write facts to disk using a template
      copy:
        content: |
          #jinja2: lstrip_blocks: True
          {% for host in groups['leafs'] %}
          Hostname: {{ hostvars[host].ansible_net_hostname }}
          OS: {{ hostvars[host].ansible_net_system }}
          Version: {{ hostvars[host].ansible_net_version }}
          Model: {{ hostvars[host].ansible_net_model }}
          Serial: {{ hostvars[host].ansible_net_serialnum }}

          {% endfor %}
        dest: ~/advanced-networking-workshop/network-documentation.txt
      run_once: yes
EOF
```
</p>
</details>

:boom: Next, let's run the playbook and have a look at the output.

<details>
<summary>Show solution</summary>
<p>

```
$ cd $LABDIR
$ ansible-playbook -i inventory network_documentation.yml 

PLAY [Document Arista switches] *****************************************************************************************************************************************************

TASK [Gather facts (eos)] ***********************************************************************************************************************************************************
[WARNING]: ansible-pylibssh not installed, falling back to paramiko
ok: [clab-containerlab-basic-leaf1]
ok: [clab-containerlab-basic-leaf2]

TASK [Display some facts] ***********************************************************************************************************************************************************
ok: [clab-containerlab-basic-leaf1] => {
    "msg": "Collecting information about leaf1 running eos 4.32.0F-36401836.4320F (engineering build)"
}
ok: [clab-containerlab-basic-leaf2] => {
    "msg": "Collecting information about leaf2 running eos 4.32.0F-36401836.4320F (engineering build)"
}

TASK [Write facts to disk using a template] *****************************************************************************************************************************************
ok: [clab-containerlab-basic-leaf1]

PLAY RECAP **************************************************************************************************************************************************************************
clab-containerlab-basic-leaf1 : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
clab-containerlab-basic-leaf2 : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

$ cat network-documentation.txt 
Hostname: leaf1
OS: eos
Version: 4.32.0F-36401836.4320F (engineering build)
Model: cEOSLab
Serial: 9E15CE1D84B7DCD52105024FFC222BA6

Hostname: leaf2
OS: eos
Version: 4.32.0F-36401836.4320F (engineering build)
Model: cEOSLab
Serial: DBE6E09113B567834960A5C72C3DD844

$
```
</p>
</details>


## 2.1.3 Using the command module

## 2.1.4 Using specific modules to configure devices
Learning about different module states (and managing VLAN configuration).

To configure VLANs for our switches we have some different approaches we can use.
Except for simply loading the switch with a full new configuration, we can use a VLAN specific Ansible module to accomplish this.

For our workshop, we use Arista devices and the module is then called [eos.eos_vlans](https://docs.ansible.com/ansible/latest/collections/arista/eos/eos_vlans_module.html).

To use this module, we need to learn a bit more how it works. The module mainly has a number of states, which governs how the configuration we define will be dealt with on our device. You will find that the different states available for the eos_vlan module is also found in many other modules, so pay extra attention here, even if you do not mean to manage VLANs using Ansible.

### 1.1.1: eos_vlan state: "merged" ← (default)
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

### 1.1.2: eos_vlan state: "replaced"
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

### 1.1.3: eos_vlan state: "overridden"
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

### 1.1.4: eos_vlan state: "deleted"
This option is self explainatory, it will remove a defined VLAN. As an example:

```
- name: Delete attributes of the given VLANs.
  arista.eos.eos_vlans:
    config:
      - vlan_id: 20
    state: deleted
```

Above configuration will delete VLAN 20 out of the device (but leave any other VLANs untouched).

### eos_vlan state: "gathered"
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

### 1.1.5: eos_vlan state: "rendered" / "parsed"
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






