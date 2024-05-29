# How to provision workshop on AWS EC2
1. Download cEOS64-lab-4.32.0F.tar.tar from Arista or elsewhere and put into role file directory.
```
cp cEOS64-lab-4.32.0F.tar.tar advanced-networking-workshop/provision/roles/containerlab/files/
```

2. Modify advanced-networking-workshop/provision/vars/vars.yml file.

3. Run ansible-navigator
```
ansible-navigator run install.yml --eei quay.io/redhat_emp1/ee-ansible-ssa --penv AWS_ACCESS_KEY_ID --penv AWS_SECRET_ACCESS_KEY --mode stdout
```
