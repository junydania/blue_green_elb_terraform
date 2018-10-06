#!/bin/bash

set -euxo pipefail

cd terraform;

terraform apply;

blue_ec2_ip=$(terraform output blue_ec2_ip);

green_ec2_ip=$(terraform output green_ec2_ip);

blue_green_elb_domain=$(terraform output blue_green_elb_domain);

cat > ./../ansible/ansible_hosts << EOF
blue:
  hosts:
    $blue_ec2_ip:
  vars:
    color: blue

green:
  hosts:
    $green_ec2_ip:
  vars:
    color: green
EOF

cd ./../ansible

ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ansible_hosts playbook.yml;

echo "Visit the URL $blue_green_elb_domain to see the current active state of your application.";
