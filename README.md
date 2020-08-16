# Introduction

Welcome to Purple Lab. This project is currently a work in progress.

# Requirements

an ESXi host

# Quick Start

## Packer

Packer builds the virtual machine templates required for the project.

1. Define your Packer variables in ```ESXi/packer/variables.json```
2. Build the Packer templates ```TBA```

## Terraform

Terraform copies the virtual machine templates and performs basic configuration.

1. Define your Terraform variables in ```ESXi/terraform.tfvars```
2. Execute ```terraform init && terraform apply```

## Ansible

Ansible performs the remaining configuration of the virtual machines.

1. Define your Ansible inventory in ```ESXI/ansible/inventory.yml```
2. Browse to ```ESXi/ansible/``` and execute ```ansible-playbook -vvv purplelab.yml```

# Acknowledgements

Detection Lab