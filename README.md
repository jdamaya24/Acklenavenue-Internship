#  CHALLENGE FOR THE INTERNSHIP POSITION AT ACKLENAVENUE

## Overview
This repository contains the steps, resources and configuration files for deploying the **Acklenavenue Challenge reporitory** using **Terraform** and **Ansible**. The deployment includes infrastructure provisioning configuration management, and application setup using Amazon Web Services (AWS).

## Tools and Technologies
- Terraform: Used for provisioning and managing infraestructure
- Ansible: Used for configuration management and software provising
- AWS: Used to host the application

## Pre-requisites
Before deploying, ensure you have the following:
1. Terraform (version 1.9.8 or above)
2. Ansible (version 2.17.6)
3. AWS account with an user that has the privileges to create the required infrastructure

## Deployment Steps
### 1. Generate the SSH key
Execute from the root of the repository the following:
- ssh-keygen -t rsa -b 4096 -C "AA"

### 2. Export the AWS variables with the credentials
Execute from the root of the repository the following:
- export AWS_ACCESS_KEY_ID="YOURACCESSKEY"
- export AWS_SECRET_ACCESS_KEY="YOURSECRETACCESSKEY"

### 3.  Provision Terraform infrastructure
Execute from the root of the repository following:
- cd terraform
- terraform init
- terraform plan
- terraform apply

### 4. Configure servers with Ansible
Execute from the root of the repository following:
- cd .. (use this if you have not exit terraform in your terminal)
- cd ansible
- ansible-galaxy install -r requirements.yaml
- ANSIBLE_CONFIG='./ansible.cfg' ansible-playbook main.yaml -D

### 5. Access the website
To get your link, run the command:
- terraform output
Please note that if the website keeps 'loading' maybe is because the link starts with "https" instead of "http". Please edit the link to access the website.

Once every step is done, you should see the website.
