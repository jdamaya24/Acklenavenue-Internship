#  CHALLENGE FOR THE INTERNSHIP POSITION AT ACKLENAVENUE

## Overview
This repository contains the steps, resources and configuration files for deploying the [Acklenavenue Challenge reporitory](https://github.com/abkunal/Chat-App-using-Socket.io) using **Terraform** and **Ansible**. The deployment includes infrastructure provisioning configuration management, and application setup using Amazon Web Services (AWS).

## Tools and Technologies
- **Terraform:** Used for provisioning and managing infraestructure
- **Ansible:** Used for configuration management and software provising
- **AWS:** Used to host the application

## Pre-requisites
Before deploying, ensure you have the following requirements:
1. Terraform (version 1.9.8 or above)
2. Ansible (version 2.17.6)
3. AWS account with an user that has the privileges to create the required infrastructure

## Deployment Steps
### 1. Generate a SSH key
Execute the following command:

``` bash
 ssh-keygen -t rsa -b 4096 -C "AA"
```
- Save the private key in `"~/.ssh/aa_id_rsa`
- Leave the passphrase empty

### 2. Export the AWS variables with the credentials
Execute from the following commands:

```bash
export AWS_ACCESS_KEY_ID="<YOURACCESSKEY>"
export AWS_SECRET_ACCESS_KEY="<YOURSECRETACCESSKEY>"
```

### 3.  Provision Terraform infrastructure
Execute from the root of the repository following:

```bash
cd terraform
terraform init
terraform apply
```

***NOTE: Save the Terraform Output for later use***

### 4. Replace the EC2 IPs
In the `ansible/inventory/inventory.yaml` inventory file, replace the `<EC2_INSTANCE_1_PUBLIC_IP>` and the `<EC2_INSTANCE_2_PUBLIC_IP>` place holders with the public IPs of the `AppInstance1` and `AppInstance2` EC2 instances.

### 5. Configure servers with Ansible
Execute from the root of the repository following:

```bash
cd .. # use this if you have not exit terraform in your terminal
cd ansible
ansible-galaxy install -r requirements.yaml
ANSIBLE_CONFIG='./ansible.cfg' ansible-playbook main.yaml -D
```

### 6. Access the Application
From the Terraform Output, past the Load Balancer URL in your browser.

 ***NOTE: If the website keeps 'loading' maybe is because the link starts with "https" instead of "http". Please edit the link to access the website.***
