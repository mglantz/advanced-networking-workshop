# How to provision workshop on AWS EC2
1. Get access to quay.io/redhat_emp1/ee-ansible-ss or download the collection.

2. Download cEOS64-lab-4.32.0F.tar.tar from Arista or elsewhere and put into role file directory.
```
cp cEOS64-lab-4.32.0F.tar.tar advanced-networking-workshop/provision/roles/containerlab/files/
```

3. Modify advanced-networking-workshop/provision/vars/vars.yml file.

4. Run ansible-navigator or ansible-playbook on install.yml
```
ansible-navigator run install.yml --eei quay.io/redhat_emp1/ee-ansible-ssa --penv AWS_ACCESS_KEY_ID --penv AWS_SECRET_ACCESS_KEY --mode stdout
```
