## Overview of lab excercises
### [Section 0: Introduction to the lab](lab-0/README.md)
```
0.1: Introduction to the workshop
0.2: Knowledge prerequisites
0.3: What this workshop is NOT about
0.4: Lab graphics
0.5: If something goes wrong
0.6: Preparing to do the lab
```

### [Section 1: Fundamentals, test automation, information related tasks](lab-1/README.md)
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

### [Section 2: Applying configuration to devices](lab-2/README.md)
```
2.1: Building a new containerlab environment
2.2: Reviewing the initial desired configuration state
2.3: Using the command module to accomplish our desired state
2.3.1: Assessing the use of the command module.
2.4: Learning about purpose specific configuration modules
2.4.1: module state: "merged" (often the default)
2.4.2: module state: "replaced"
2.4.3: module state: "overridden"
2.4.4: module state: "deleted"
2.4.5: module state: "gathered"
2.4.6: module state: "rendered" / "parsed"
2.5: Reset your lab environment
2.6: Using purpose specific modules to archieve the desired configuration state
2.6.1: Assessing the use of purpose specific configuration modules
2.7: Using config modules to make changes
2.7.1: Using the config module to load static config files into devices
2.7.2: Using the config module to inject lines of config into devices
2.7.3: Using the config module to load dynamic config files into devices
```

### [Section 3: Applying best practices to build a BGP EVPN architecture](lab-3/README.md)
```
3.1 Review of containerlab and desired state device configuration
3.2 Automating your network
3.3. Validating your setup
```
