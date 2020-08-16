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

# Lab environment

## Splunk

Operating System: Ubuntu 20.04 LTS

Packages installed:

- Splunk Enterprise 8.0.5
- Guacamole

## Domain Controller

Operating System: Windows Server 2016

Packages:

- Notepad++
- 7-Zip
- Microsoft Edge

### Log Configuration

Splunk Universal Forwarder 8.0.5

- [https://splunkbase.splunk.com/app/742/](Splunk Add-On for Microsoft Windows 8.0.0)
- [https://splunkbase.splunk.com/app/1914](Splunk Add-On for Microsoft Sysmon 10.6.2)

# Acknowledgements

Inspired by [https://github.com/clong/DetectionLab](Detection Lab)