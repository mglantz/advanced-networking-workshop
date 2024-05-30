# Section 1: Fundamentals, test automation, information related tasks
In this section, you will learn about some of the different main approaches when automating against network devices.
At the end of this section, you will have learned about fundamentals, how to perform automated testing and using the information we can pull from the network to perform common tasks.

## Overview
This is what we will learn about in this first section of the workshop.

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
1.1.4: Using specific modules to configure devices
1.1.5: Using config modules to configure devices
1.1.6: Using templates
```
## 1.1: Different Ansible approaches to automating network devices
Ansible is versatile, meaning you can approach automating your network in many different ways, with that said, there are some fundamental likeness which you will find, also across different network vendors which we will deal with in this part of the workshop. Except for there being some general approaches which applies to your actual automation of network devices, the development approach is very much similiar, no matter what thing you use Ansible to automate.

:thumbsup: With that said, we would like to remind you of Ansible's three guiding development principles:
* Complexity kills productivity (keep it simple, it makes it robust, scalable and easy to maintain)
* Optimize for readability (makes for easier collaboration, maintenance and makes it more robust)
* Think declaratively (Ansible is a state engine, do not try to 'code' with playbooks, that you can do with modules)

## 1.1.1: Vendor differences
When doing Ansible automation outside of the domain of networking, we are used to use the same settings and the same modules, even when we automate against different operating systems. When it comes to networking, this is not always true.

Main differences between network vendors are:
* How you connected to the devices. [Explore the list of options here](https://docs.ansible.com/ansible/latest/network/user_guide/platform_index.html)
* What modules you use to perform tasks like, fact gathering, configuration changes, command execution. [Explore the list of options here](https://docs.ansible.com/ansible/latest/network/user_guide/platform_index.html#settings-by-platform)

## 1.1.2 Network test automation (using ContainerLab)
Writing Ansible automation may not feel like programming, but make no misstake, that is what you are doing. A fundamental of programming is testing your code.
The basics of testing your Ansible code includes static code analysis using standard Ansible tools such as ansible-lint, yamllint, ansible-test or molecule.
You can read more about this on the [ansible.com dev-guide for testing](https://docs.ansible.com/ansible/latest/dev_guide/testing.html).

When things becomes specific for networking, is when we are doing more proper integration tests, where we test to see if the Ansible automation actually does what it's supposed to do. In the world of normal operating systems, this is normally done by spinning up test VMs or containers and testing if your playbooks works against those. But in the world of networking, things are not as far ahead yet and it's not common that people use virtualized or containerized test environments for router or switch related configuration changes.

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

:boom: Task 1: If you can. [Click here, to have a look at this introductionary video on YouTube, for containerlab](https://www.youtube.com/watch?v=xdi7rwdJgkg).

## 1.1.2.1 Creating a containerlab environment
In this section, you will learn how to create your first containerlab environment, which we will use to test against.
Containerlab uses a few main components:
* The containerlab cli tool
* The containerlab yml definition which decides how to build things
* A container engine, such as podman or docker.
* A Linux operating system to run it all on

An example deployment is shown below. When running the containerlab command to deploy a setup of network devices, you feed it a so called topology file, which containers how things should be setup. In our example, it's called containerlab-basic.yml. Command output includes the management IP addresses of the devices you have created.
```
$ sudo containerlab --runtime podman deploy -t containerlab-basic.yml
INFO[0000] Containerlab v0.54.2 started                 
INFO[0000] Parsing & checking topology file: containerlab-basic.yml 
WARN[0004] Unable to load kernel module "ip_tables" automatically "load ip_tables failed: exec format error" 
INFO[0000] Destroying lab: containerlab-basic           
INFO[0010] Removing containerlab host entries from /etc/hosts file 
INFO[0010] Removing ssh config for containerlab nodes   
INFO[0010] Removing /home/mglantz/advanced-networking-workshop/containerlab/clab-containerlab-basic directory... 
INFO[0010] Creating lab directory: /home/mglantz/advanced-networking-workshop/containerlab/clab-containerlab-basic 
INFO[0011] Running postdeploy actions for Arista cEOS 'leaf2' node 
INFO[0011] Created link: leaf1:eth9 <--> leaf2:eth9     
INFO[0011] Created link: leaf1:eth10 <--> leaf2:eth10   
INFO[0011] Running postdeploy actions for Arista cEOS 'leaf1' node 
INFO[0029] Adding containerlab host entries to /etc/hosts file 
INFO[0029] Adding ssh config for containerlab nodes     
+---+-------------------------------+--------------+------------------------+------+---------+------------------+-----------------------+
| # |             Name              | Container ID |         Image          | Kind |  State  |   IPv4 Address   |     IPv6 Address      |
+---+-------------------------------+--------------+------------------------+------+---------+------------------+-----------------------+
| 1 | clab-containerlab-basic-leaf1 | bebd3333ec69 | localhost/ceos:4.32.0F | ceos | running | 172.20.20.147/24 | 2001:172:20:20::93/64 |
| 2 | clab-containerlab-basic-leaf2 | c5ca2e2609e5 | localhost/ceos:4.32.0F | ceos | running | 172.20.20.146/24 | 2001:172:20:20::92/64 |
+---+-------------------------------+--------------+------------------------+------+---------+------------------+-----------------------+
```

Looking into the directory where we ran the containerlab command, that will create a lab directory, below called clab-containerlab-basic:
There is also a config directory where you put your switch configuration files.
```
$ ls
clab-containerlab-basic config containerlab-basic.yml
```

In the lab relate directory, you will find an automatically generated ansible-inventory.yml file, a file with authorized SSH keys, a topology file, describing details about your deployment, including IP address of the management interface, mac-addresses, etc. And if you look deeper, there is a separate folder which is named the node names of the devices you deployed, below called "leaf1" and "leaf2" in the example below:

```
$ ls clab-containerlab-basic/
ansible-inventory.yml  authorized_keys	leaf1  leaf2  topology-data.json
```

If we dive deeper into those device specific folders, we will find the devices flash storage there, with the files normal files we'd expected to find.
```
$ ls clab-containerlab-basic/leaf1/flash/
aboot			boot-config  fastpkttx.backup  if-wait.sh	 persist   SsuRestoreLegacy.log  startup-config      tpm-data
AsuFastPktTransmit.log	debug	     Fossil	       kickstart-config  schedule  SsuRestore.log	 system_mac_address
```

Now that you understand a bit better about containerlab, it's time to create your own network test environment.

:boom: Task 1: Go to your $LABDIR/containerlab directory.
```
$ cd $LABDIR/containerlab
```
---

:boom: Task 2: Create a simple containerlab definition, which spins up two Arista cEOS switches which are connected to each other, as follows:
* Save your work in the containerlab directory and name the file lab1.yml.
* kinds: should be ceos and image needs to be set to: localhost/ceos:4.32.0F
* Call your nodes leaf1 and leaf2
* The switches should be connected to each other via ports eth9 on and eth10 (leaf1:eth9 to leaf2:eth9 and leaf1:eth10 to leaf2:eth10).
* startup-config should be ~/advanced-networking-workshop/containerlab/configs/leaf1-start.cfg for leaf1 and leaf2-start.cfg for leaf2.

:exclamation: To get an idea of the basic structure of your YAML based topology file, [click here: https://containerlab.dev/quickstart/](https://containerlab.dev/quickstart/).


<details>
<summary>:unlock: Show solution: Task 2</summary>
<p>
  
* Create lab1.yml as follows:
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

```
End of solution: Task 2.
```
</p>
</details>

---

:boom: Task 3: Now, let's review the configuration used to start up our switches. Run the "cat" command on your leaf1/2.cfg files to view them.


<details>
<summary>:unlock: Show example solution: Task 3</summary>
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

```
End of solution: Task 3.
```
</p>
</details>

:exclamation: As you can see, there are a few things we need to setup for us to use the devices for testing, namely:
* A configured management interface which we can connect to
* An initial user which we can connect with
* Means to authenticate with our user (in this case, both a password and a SSH key is configured).

If you SSH to a device in your setup, you will authenticate automatically, that is because the SSH key has been added in your environment.

---

:boom: Task 4: Next, you are ready to start your lab environment. Use the "sudo containerlab" CLI command, accordingly:
* Use --runtime podman
* If you have already tried to deploy the lab once, add the --reconfigure parameter.
* Run "sudo containerlab --help" to get more information.
* We need to use sudo, because the workloads are very priviledged in nature.

:exclamation: :exclamation: Below error message is expected and is nothing to worry about. :exclamation: :exclamation:
```
WARN[0004] Unable to load kernel module "ip_tables" automatically "load ip_tables failed: exec format error" 
```


<details>
<summary>:unlock: Show example solution: Task 4</summary>
<p>

```
$ sudo containerlab --runtime podman deploy -t lab1.yml --reconfigure
INFO[0000] Containerlab v0.54.2 started                 
INFO[0000] Parsing & checking topology file: containerlab-basic.yml 
WARN[0004] Unable to load kernel module "ip_tables" automatically "load ip_tables failed: exec format error" 
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

```
End of solution: Task 4
```
</p>
</details>

---

:boom: Task 5: Run the "scripts/ansibe_hosts.sh basic" command to generate a properly configured Ansible inventory ($LABDIR/inventory) and accept SSH fingerprints
```
$ ../scripts/ansible_hosts.sh basic
```
Please note that a successful run of the command does not generate any output. 

---

:boom: Task 6: Validate that your have a correctly configured inventory file.
```
$ cd $LABDIR
$ cat inventory
```

<details>
<summary>:unlock: Show example inventory file</summary>
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

```
End of solution.
```
</p>
</details>

---

:boom: Task 7: Next, SSH to your switches using the admin user and validate ports Ethernet9 and 10 are connected.


<details>
<summary>:unlock: Show solution</summary>
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

```
End of solution: Task 7.
```
</p>
</details>

:star: If you have time, you can also validate that the overall running configuration is correct.

---

:boom: Task 8: Next create a simple playbook which you save in the advanced-networking-workshop directory, which uses the ansible.builtin.ping module to ping the switches.

<details>
<summary>:unlock: Show solution: Task 8</summary>

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

```
End of solution: Task 8.
```
</p>
</details>

---

:boom: Task 9: Next, run a static code analysis on your playbook, using the "ansible-lint" command.

<details>
<summary>:unlock: Show solution: Task 9</summary>

```
$ ansible-lint ping.yml 

Passed: 0 failure(s), 0 warning(s) on 1 files. Last profile that met the validation criteria was 'production'.
```

```
End of solution: Task 9.
```
</p>
</details>

:exclamation: If you had 0 failures and 0 warnings, you can go on to the next task, otherwise, fix your issues.

---

:boom: Task 10: Next, run the basic playbook stored in $LABDIR/ping.yml against our new switches.

<details>
<summary>:unlock: Show solution: Task 9</summary>
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

```
End of solution: Task 9.
```
</p>
</details>

---

Well done! You successfully executed most parts of what we would expected to see in an automated CI/CD pipeline, meaning:
* Creation of an Ansible playbook
* Run static code analysis on Ansible playbook
* Create test environment
* Run playbook against test environment

:star: If you like, you can re-deploy your environment and do the test over again.

<details>
<summary>:unlock: Show helpful clues on re-deployment</summary>
<p>

Don't forget to add --reconfigure to your "sudo containerlab" command and re-run the "scripts/ansible_host.sh basic" command doing so.

```
End of clue.
```
</p>
</details>

The only thing we have not covered here, is how you would execute the tasks automatically in a CI/CD pipeline, the reason for that is that it would differ depending on what CI engines you run. With that said, most CI engines supports shell scripting, meaning you almost only have to add the commands you leared about here, to automate the process.

## 1.1.3 Gathering information about your devices
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

## 1.1.3.1 Using the command module
The command module allows you to inject any number of commands into a network device. This allows you to directly use existing knowledge about network device CLIs, in your Ansible automation. Different network vendors will have their own versions of the command module. For example:

* [Cisco IOS command](https://docs.ansible.com/ansible/latest/collections/cisco/ios/ios_command_module.html#ansible-collections-cisco-ios-ios-command-module)
* [Arista EOS command](https://docs.ansible.com/ansible/latest/collections/arista/eos/eos_command_module.html#ansible-collections-arista-eos-eos-command-module)
* [Juniper JunOS command](https://docs.ansible.com/ansible/latest/collections/junipernetworks/junos/junos_command_module.html#ansible-collections-junipernetworks-junos-junos-command-module)

Even if you can use this approach to make configuration changes, that is not recommended, if you do not have to. Overall, it is recommended and more common to use a config module or specific modules designated to do specific config change, there are good reasons for that, including:

* The command module is not idempotent, it will run a command, every time.
* Not using Ansible modules, you are directly implementing a specific version of the network CLI, prone to breakage in the future (what happens when a command changes?)
* Ansible is meant to be simple and declarative, using the command module is more complicated is less declarative.

So, you can see that the command module does violate several of the design principles for Ansible. 

With this said, a time when the command module often is very useful in your Ansible automation, is when you are looking to find specific information, eg. thing you would find when running various "show" related commands in your network CLI. Some examples:

* show int stat
* show cdp/lldp neighbor
* show arp int Xx0
* show ip route

:boom: Task 1: Create a playbook which displays a to you useful piece of information using the eos_command module and a show command. Print that information out to the screen using the debug module. Name the playbook show_info.yml and store it in the $LABDIR root directory.

<details>
<summary>:unlock: Show solution: Task 1</summary>
<p>

```
- name: "Show int stat on leaf switches"
  hosts: leafs
  gather_facts: no
  become: yes
  tasks:
    - name: Show summary of interface statuses
      arista.eos.eos_command:
        commands: "sh int stat"
      register: sh_int_stat

    - name: Print collected interface information
      debug:
        msg: "{{ sh_int_stat.stdout_lines }}"
```

```
End of solution: Task 1.
```
</p>
</details> 

---

:boom: Task 2: Now, let's run the playbook you created.

<details>
<summary>:unlock: Show solution: Task 2</summary>
<p>

```
$ ansible-playbook -i inventory show_info.yml

PLAY [Show int stat on leaf switches] ***********************************************************************************************************************************************

TASK [Show summary of interface statuses] *******************************************************************************************************************************************
[WARNING]: ansible-pylibssh not installed, falling back to paramiko
ok: [clab-containerlab-basic-leaf2]
ok: [clab-containerlab-basic-leaf1]

TASK [Print collected interface information] ****************************************************************************************************************************************
ok: [clab-containerlab-basic-leaf1] => {
    "msg": [
        [
            "Port       Name   Status       Vlan     Duplex Speed  Type            Flags Encapsulation",
            "Et9               connected    1        full   1G     EbraTestPhyPort                   ",
            "Et10              connected    1        full   1G     EbraTestPhyPort                   ",
            "Ma0               connected    routed   a-full a-1G   10/100/1000"
        ]
    ]
}
ok: [clab-containerlab-basic-leaf2] => {
    "msg": [
        [
            "Port       Name   Status       Vlan     Duplex Speed  Type            Flags Encapsulation",
            "Et9               connected    1        full   1G     EbraTestPhyPort                   ",
            "Et10              connected    1        full   1G     EbraTestPhyPort                   ",
            "Ma0               connected    routed   a-full a-1G   10/100/1000"
        ]
    ]
}

PLAY RECAP **************************************************************************************************************************************************************************
clab-containerlab-basic-leaf1 : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
clab-containerlab-basic-leaf2 : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0 
```

```
End of solution: Task 2
```
</p>
</details>

Well done, later on in the workshop, you will learn some different methods where you can use this type of information to automate various common tasks.

### 1.1.3.2 Performing backups
A very common scenario when we are pulling information from the network devices is when we are performing backups. You can use the various facts gathering modules to perform a backup, but normally there is a config module you can use for this specific purpose, which is simpler to use. Again, like the fact gathering module, there are unique versions of the config modules for different network vendors. For example:

* [Cisco config module](https://docs.ansible.com/ansible/latest/collections/cisco/ios/ios_config_module.html)
* [Arista config module](https://docs.ansible.com/ansible/latest/collections/arista/eos/eos_config_module.html)
* [Juniper config module](https://docs.ansible.com/ansible/latest/collections/junipernetworks/junos/junos_config_module.html)

Now it's time to do something.

:boom: Task 1: Read up on the Arista config module and create a playbook called arista_backup.yml which backups the documentation to the backups folder located in the lab home directory.

:exclamation: You will need to use "become: yes" for this operation.

<details>
<summary>:unlock: Show solution: Task 1</summary>
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

```
End of solution: Task 1
```
</p>
</details>

---

:boom: Task 2: Now, let's review the backed up configuration, it's located in $LABDIR/backups


<details>
<summary>:unlock: Task 2: Show solution</summary>
<p>

```
$ cat $LABDIR/backups/clab-containerlab-basic-leaf1/clab-containerlab-basic-leaf1.cfg
...
```

```
End of solution: Task 2
```
</p>
</details>

Well done, creating backups does not have to be more difficult. Of course, normally you would put them somewhere special, a location also backed up by some backup software.

### 1.1.3.1 Documenting the network
Ansibles ability to pull information from your network devices allows you to automate something which not all organizations has - network documentation.

We will review a more basic example of creating network documentation, where we write information about our network devices to a plain text file. With that said, this information may as well be written to your CMDB system, using the ansible.builtin.uri module (or more specific one) to do a API call to some external system.

:boom: Task 1: Create a playbook called network_documentation.yml which uses the "arista.eos.eos_facts" module to gather facts from your switches, then use the copy module and jinja templating to save facts you care about, to the file network-documentation.txt. 

An example of how to write information to a file using copy and jinja:
```
    - name: Write facts to disk using a template
      copy:
        content: |
          #jinja2: lstrip_blocks: True
          {% for host in groups['leafs'] %}
          Hostname: {{ hostvars[host].ansible_net_hostname }}
          {% endfor %}
        dest: ~/advanced-networking-workshop/network-documentation.txt
```

An example of how to use the "ansible" command to review facts.
```
$ ansible -i inventory leafs -m arista.eos.eos_facts
```

:exclamation: This is an advanced ask and there is no shame in copying the solution below in true open source fashion.

<details>
<summary>:unlock: Show solution: Task 1</summary>
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

```
End of solution: Task 1
```
</p>
</details>

---

:boom: Task 2: Next, let's run the playbook and have a look at the output.


<details>
<summary>:unlock: Show solution: Task 2</summary>
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

```
End of solution: Task 2
```
</p>
</details>

## 1.1.3.4: Adding intelligence to your playbooks
Now that you have learned about different methods to pull information from your network devices. Let's review how you can further use that information to make your playbooks smarter. Even though, we have learned that trying to do programming in playbooks violates basic design tenants of Ansible, we will now have a look at how close we can get, without ending up in an unmaintainable mess.

First off, let's review the different useful tools which helps us to process information gathered by facts and commands.

:boom: Task 1: Have a brief look at the different tools below and imagine how they may be useful.

Ansible modules:
* [assert](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/assert_module.html)
* [fail](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/fail_module.html)

The Ansible conditional:
* [when](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_conditionals.html)

Variable filenames:
* [Selecting filenames based on facts](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_conditionals.html#selecting-variables-files-or-templates-based-on-facts)

Managing error handling:
* [Error handling in playbooks](https://docs.ansible.com/ansible/latest/playbook_guide/playbooks_error_handling.html)

Now, let's create some smarter versions of the playbooks we have previously create.

---

:boom: Task 2: Create a version of below playbook which only uses the eos_facts module when you have detected that it is an Arista switch.
```
- name: "Gather facts from Arista switches"
  hosts: leafs 
  gather_facts: no

  tasks:
    - name: Gather facts (eos)
      arista.eos.eos_facts:
```

<details>
<summary>:unlock: Show solution: Task 2</summary>
<p>

```
- name: "Gather facts from Arista switches"
  hosts: leafs
  gather_facts: no

  tasks:
    - name: Gather facts (eos)
      arista.eos.eos_facts:
      when: ansible_net_system == 'eos'
```

```
End of solution: Task 2
```
</p>
</details>

---

:boom: Task 3: Next, add a eos_command task which runs "show version", save the output using register and then add an assert tas which validates that the output from "show version" DOES NOT include "Architecture: s390"

:exclamation: Because of the output we get from the "show version" command, we need to process the output and used search to find what we are looking for, like so:
```
# Below is true, if we DO NOT find it. Eg, list of hits less than 1.
ansible.builtin.assert:
  that:
    - "show_version.stdout_lines | select('search', 'Architecture: s390') | list | count < 1"

# To construct something which is true, IF we find it, use: count > 0. Eg, list of hits is more than 0.
```
:star: Use a fail_msg and success_msg.

<details>
<summary>:unlock: Show solution: Task 3</summary>
<p>

```
- name: "Gather facts from Arista switches"
  hosts: leafs
  gather_facts: no

  tasks:
    - name: Gather facts (eos)
      arista.eos.eos_facts:

    - name: Tell user we found an Arista switch
      debug:
        msg: "Arista switch detected"
      when: ansible_net_system == 'eos'

    - name: Collect show version information
      arista.eos.eos_command:
        commands: "show version"
      register: show_version

    - name: Ensure no strange CPU architectures are detected
      ansible.builtin.assert:
        that:
          - "show_version.stdout_lines | select('search', 'Architecture: s390') | list | count < 1"
        fail_msg: "Oh no"
        success_msg: "All is well"
```

```
End of solution: Task 3
```
</p>
</details>

---

:boom: Task 4: And now you run the playbook against your inventory

<details>
<summary>:unlock: Show solution and expected output: Task 4</summary>
<p>

```
$ ansible-playbook -i inventory eos_facts.yml 

PLAY [Gather facts from Arista switches] ********************************************************************************************************************************************

TASK [Gather facts (eos)] ***********************************************************************************************************************************************************
[WARNING]: ansible-pylibssh not installed, falling back to paramiko
ok: [clab-containerlab-basic-leaf2]
ok: [clab-containerlab-basic-leaf1]

TASK [Tell user we found an Arista switch] ******************************************************************************************************************************************
ok: [clab-containerlab-basic-leaf1] => {
    "msg": "Arista switch detected"
}
ok: [clab-containerlab-basic-leaf2] => {
    "msg": "Arista switch detected"
}

TASK [Collect show version information] *********************************************************************************************************************************************
ok: [clab-containerlab-basic-leaf1]
ok: [clab-containerlab-basic-leaf2]

TASK [Ensure no strange CPU architectures are detected] *****************************************************************************************************************************
ok: [clab-containerlab-basic-leaf1] => {
    "changed": false,
    "msg": "All is well"
}
ok: [clab-containerlab-basic-leaf2] => {
    "changed": false,
    "msg": "All is well"
}

PLAY RECAP **************************************************************************************************************************************************************************
clab-containerlab-basic-leaf1 : ok=4    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
clab-containerlab-basic-leaf2 : ok=4    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

```
End of solution: Task 4
```
</p>
</details>

---

:boom: Task 5: Finally you are going to use variable file naming and the fail module. Do this:
* Load a variable file, using a task which runs after the eos_facts task.
* Use the ansible.builtin.include_vars module to load your variable file. 
* Use the {{ ansible_net_system }} fact (it will be set to "eos") in the name of your vars file.
* Set the following variable in your vars file: switch_sla: "premium"
* Use the fail module and a when statement to check if switch_sla was set to anything but "premium"
* Make up a suitable msg for the fail module.

:exclamation: Get some clues of how to do this by reading here: [include_vars module examples](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/include_vars_module.html#examples) and also here [fail module examples](https://docs.ansible.com/ansible/latest/collections/ansible/builtin/fail_module.html#examples)
:exclamation: Please note that 


<details>
<summary>:unlock: Show solution: Task 5</summary>
<p>

```
# In vars/eos.yml:
---
switch_sla: "premium"

# Your playbook:
- name: "Gather facts from Arista switches"
  hosts: leafs
  gather_facts: no

  tasks:
    - name: Gather facts (eos)
      arista.eos.eos_facts:

    - name: Load vars file based on ansible_net_system
      ansible.builtin.include_vars: "vars/{{ ansible_net_system }}.yml"

    - name: Tell user we found an Arista switch
      debug:
        msg: "Arista switch detected"
      when: ansible_net_system == 'eos'

    - name: Collect show version information
      arista.eos.eos_command:
        commands: "show version"
      register: show_version

    - name: Ensure no strange CPU architectures are detected
      ansible.builtin.assert:
        that:
          - "show_version.stdout_lines | select('search', 'Architecture: s390') | list | count < 1"
        fail_msg: "Oh no"
        success_msg: "All is well"

    - name: Fail if SLA is not premium
      fail:
        msg: "Warning: SLA is {{ switch_sla }}"
      when: switch_sla != "premium"
```

```
End of solution: Task 5
```
</p>
</details>

---

:boom: Task 6: And now you run your updated playbook. After having done that, try and change the switch_sla variable to something else than "premium" to see that your fail and when task does work.


<details>
<summary>:unlock: Show solution: Task 6</summary>
<p>

```
$ ansible-playbook -i inventory eos_facts.yml 

PLAY [Gather facts from Arista switches] ********************************************************************************************************************************************

TASK [Gather facts (eos)] ***********************************************************************************************************************************************************
[WARNING]: ansible-pylibssh not installed, falling back to paramiko
ok: [clab-containerlab-basic-leaf2]
ok: [clab-containerlab-basic-leaf1]

TASK [Load vars file based on ansible_net_system] ***********************************************************************************************************************************
ok: [clab-containerlab-basic-leaf1]
ok: [clab-containerlab-basic-leaf2]

TASK [Tell user we found an Arista switch] ******************************************************************************************************************************************
ok: [clab-containerlab-basic-leaf1] => {
    "msg": "Arista switch detected"
}
ok: [clab-containerlab-basic-leaf2] => {
    "msg": "Arista switch detected"
}

TASK [Collect show version information] *********************************************************************************************************************************************
ok: [clab-containerlab-basic-leaf1]
ok: [clab-containerlab-basic-leaf2]

TASK [Ensure no strange CPU architectures are detected] *****************************************************************************************************************************
ok: [clab-containerlab-basic-leaf1] => {
    "changed": false,
    "msg": "All is well"
}
ok: [clab-containerlab-basic-leaf2] => {
    "changed": false,
    "msg": "All is well"
}

TASK [debug] ************************************************************************************************************************************************************************
ok: [clab-containerlab-basic-leaf1] => {
    "msg": "premium"
}
ok: [clab-containerlab-basic-leaf2] => {
    "msg": "premium"
}

TASK [Fail if SLA is not premium] ***************************************************************************************************************************************************
skipping: [clab-containerlab-basic-leaf1]
skipping: [clab-containerlab-basic-leaf2]

PLAY RECAP **************************************************************************************************************************************************************************
clab-containerlab-basic-leaf1 : ok=6    changed=0    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0   
clab-containerlab-basic-leaf2 : ok=6    changed=0    unreachable=0    failed=0    skipped=1    rescued=0    ignored=0  
```

```
End of solution: Task 6
```
</p>
</details>

Well done, now you know more about some of the useful features in Ansible which can make your playbooks smarter. This is something we will be using in the next section, where we deal with operational use-cases.

## 1.1.3.5: Operational use-cases
Armed with knowledge about how we can pull information from devices and also how we can evaluate that information, it would not be strange if some of you already have considered how this can be used to automate some common operational use-cases.

A very common operational task which fits what we have learned like a glove, is troubleshooting.
Let's have a look at a practical example, which is helping to troubleshoot connectivity issues for a server to a leaf/access switch. The idea is that we get a playbook which will print out the ARP table for a given port.

:boom: Task 1: Create a playbook which use the arista.eos.eos_command module to display the ARP table on a specific port, also ensure that:
* Call the playbook arp_check.yml
* The name of the port we look at should be set using a variable called interface_name, allowing us to set it at runtime.
* Name the variable interface_name set it to be Ethernet9 by default.
* You print out the registered result using the debug module.

<details>
<summary>:unlock: Show hint: Task 1</summary>
<p>

Use the Arista CLI command:
```
"show arp int {{ interface_name }}"
```

Set variable with default value like so:
```
- name: Check for MAC-address
  hosts: leafs
  vars:
    interface_name: "Ethernet9"
  tasks:
...
```
</p>
</details>


<details>
<summary>:unlock: Show solution: Task 1</summary>
<p>

* Create playbook arp_check.yml as such:
```
---
- name: Check ARP table on port
  hosts: leafs
  vars:
    interface_name: Ethernet9
  tasks:
    - name: "Fetch ARP table for {{ interface_name }}"
      arista.eos.eos_command:
        commands: "show arp int {{ interface_name }}"
      register: arp_table

    - name: "Printing ARP table for {{ interface_name }}"
      ansible.builtin.debug:
        msg: " {{ arp_table.stdout_lines }}"
```

```
End of solution: Task 1
```
</p>
</details>

---

:boom: Task 2: Now, run the troubleshooting playbook. For it to be useful, pass -e "interface_name=Ma0" and --limit nodename_from_inventory to the ansible-playbook command, allowing you to target what switch and what port to run against.

<details>
<summary>:unlock: Show solution: Task 2</summary>
<p>

```
$ ansible-playbook -i inventory arp-check.yml -e "interface_name=Ma0" --limit "clab-containerlab-basic-leaf1"

PLAY [Check ARP table on port] ******************************************************************************************************************************************************

TASK [Gathering Facts] **************************************************************************************************************************************************************
[WARNING]: ansible-pylibssh not installed, falling back to paramiko
ok: [clab-containerlab-basic-leaf1]

TASK [Fetch ARP table for Ma0] ******************************************************************************************************************************************************
ok: [clab-containerlab-basic-leaf1]

TASK [Printing ARP table for Ma0] ***************************************************************************************************************************************************
ok: [clab-containerlab-basic-leaf1] => {
    "msg": " [['Address         Age (sec)  Hardware Addr   Interface', '172.20.20.1       0:00:00  72a0.ec69.8301  Management0']]"
}

PLAY RECAP **************************************************************************************************************************************************************************
clab-containerlab-basic-leaf1 : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

```
End of solution: Task 2
```
</p>
</details>

---

:boom: Task 3: Next, let's create a troubleshooting playbook which detects ports which are in a "notconnect" state. As follows:
* Name the playbook: check_port.yml
* Use the arista.eos.eos_command module and print out the result using debug.
* Use the ansible.builtin.assert module to assess that ports are not in a "notconnect" state.
* :star: If you have time: If a port is in notconnect, gather further debug information about all ports.

<details>
<summary>:unlock: Show hints: Task 3</summary>
<p>

1. Use: "show int stat" to find status of all ports.
2. Remember what you learned about assessing tricky output using assert? You'll need the same solution.
3. On the assert task, use: ignore_errors: yes. This is because we want it to assess all things and not stop when assertions are wrong.
4. If are you doing the :star: extra task: Use register on the assert task, then use a block which you tie to a: "when: port_assessment is failed"
</p>
</details>

<details>
<summary>:unlock: Show solution: Task 3</summary>
<p>

```
---
- name: Check for port issues
  hosts: leafs
  vars:
    port_state: "notconnect"
  tasks:
    - name: "Fetch port status on switch"
      arista.eos.eos_command:
        commands: "show int stat"
      register: sh_int_stat

    - name: "Checking so that we DO NOT have {{ port_state }} port states on switch"
      ansible.builtin.assert:
        that:
          - "sh_int_stat.stdout_lines | select('search', port_state) | list | count < 1"
        fail_msg: "Found ports with line protocol down."
        success_msg: "All ports are connected."
      register: port_assessment
      ignore_errors: yes

# Extra task
    - name: "Fetch debug info in case of {{ port_state }} port states"
      block:
        - name: "Fetch interface information"
          arista.eos.eos_command:
            commands:
              - sh interfaces|inc Ethernet[0-9]
              - sh int stat
              - sh int counters errors
          register: port_status

        - name: "Print interface information"
          ansible.builtin.debug:
            msg: "{{ port_status.stdout_lines }}"
      when: port_assessment is failed
```

```
End of solution: Task 3
```
</p>
</details>

---

:boom: Task 4: Now let's run the troubleshooting playbook we just created. Limit what switch it runs on using the --limit command.


<details>
<summary>:unlock: Show solution and output: Task 4</summary>
<p>

```
$ ansible-playbook -i inventory port_check.yml --limit "clab-containerlab-basic-leaf1"

PLAY [Check for port issues] ********************************************************************************************************************************************************

TASK [Gathering Facts] **************************************************************************************************************************************************************
[WARNING]: ansible-pylibssh not installed, falling back to paramiko
ok: [clab-containerlab-basic-leaf1]

TASK [Fetch port status on switch] **************************************************************************************************************************************************
ok: [clab-containerlab-basic-leaf1]

TASK [Checking so that we DO NOT have notconnect port states on switch] *************************************************************************************************************
ok: [clab-containerlab-basic-leaf1] => {
    "changed": false,
    "msg": "All ports are connected."
}

TASK [Fetch interface information] **************************************************************************************************************************************************
skipping: [clab-containerlab-basic-leaf1]

TASK [Print interface information] **************************************************************************************************************************************************
skipping: [clab-containerlab-basic-leaf1]

PLAY RECAP **************************************************************************************************************************************************************************
clab-containerlab-basic-leaf1 : ok=3    changed=0    unreachable=0    failed=0    skipped=2    rescued=0    ignored=0   
```

```
End of solution: Task 4
```
</p>
</details>

Well done! We are now ready to move on to how we can work with configuration of network devices. Which we will deal with in the next section.

```
End-of-lab
```
[Go to the next lab, lab 2](../lab-2/README.md)

