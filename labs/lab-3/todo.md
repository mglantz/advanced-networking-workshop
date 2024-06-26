# Section 3: Applying best practices to build a BGP EVPN architecture
This is the last and final part of the workshop, in which you will get to apply all your knowledge to create a fully functioning BGP EVPN spine/leaf setup.

:exclamation: This is a free form excercise, so if you struggeled a little bit before, this may be an excercise you may want to do later on as you have built more experience.

If you want to read up on BGP EVPN based architectures, you can read David Varnum's excellent writup on the topic, here:
* [Arista BGP EVPN Overview and concepts](https://overlaid.net/2018/08/27/arista-bgp-evpn-overview-and-concepts/)

And this blog, where David Varnum walks through the required configuration:
* [Arista BGP EVPN - Configuration example](https://overlaid.net/2019/01/27/arista-bgp-evpn-configuration-example/)

## Overview
```
3.1 Review of containerlab and desired state device configuration
3.2 Option 1: Hackathon: Setup your network
3.3 TODO: Option 2: Step-by-step setup using Ansible
3.3.1. Configure Multi-Chassis Link Aggregation (MLAG)
3.3.2. Configure MLAG – Dual-Active Detection (aka Peer Keepalive)
3.3.3 Configure Underlay Point-to-Point Interfaces
3.3.4. Configure Underlay Point-to-Point Interfaces - Leaf-to-Leaf
3.3.5. Configure Loopbacks for BGP Peering
3.3.6. Configure BGP Process
3.3.7. Configure Underlay EBGP Neighbors
3.3.8. Configure Underlay IBGP Neighbors
3.3.9. Activating BGP
3.3.10. Enable EVPN Capability
3.3.11. Configure BGP EVPN Overlays - Leaf-to-Spine
3.3.12. Configure BGP EVPN Overlay - Spines-to-Leafs
3.3.13. Validating EVPN Neighbors
3.3.14. Configure VXLAN Tunnel Endpoints (VTEP)
3.3.15. Validating host to host communication
```

TODO


