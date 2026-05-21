# Infrastructure Automation - Azure Virtual Machine Provisioning

This directory contains the production-grade, highly secure, and reproducible Terraform configurations to provision an Azure Linux Virtual Machine for the **AI Mock Interview Platform**.

This infrastructure code isolates database and API backend components internally, opening only mandatory ports to the public internet.

---

## Directory Structure

* **`provider.tf`**: Sets provider parameters, constraints, and version lockouts (`>= 1.5.0` for Terraform, `~> 3.90.0` for AzureRM).
* **`variables.tf`**: Parametrizes all environment-specific values with safe defaults, leaving zero hardcoded configuration.
* **`main.tf`**: Provisions the Azure resource chain in order of dependencies: Resource Group, VNet, Subnet, Static Public IP, NSG, Standalone Security Rules, NIC, NIC-NSG Association, and the Virtual Machine (Ubuntu 22.04 LTS).
* **`outputs.tf`**: Exposes critical outputs such as the public static IP, hostnames, and pre-built SSH connection strings.

---

## Architectural & Network Security Highlights

> [!IMPORTANT]
> **Strict Firewall Policy (Minimum Ingress Boundary)**
> * **Public Traffic**: Only Port `22` (SSH management from the operator) and Port `3000` (React frontend client) are exposed via the Network Security Group. Optionally, Ports `80` and `443` can be toggled open via variables.
> * **Internal Isolation**: Ports `5432` (PostgreSQL) and `8080` (Spring Boot API) **must never** be exposed to the public internet. Traffic flows securely inside the host VM via the internal Docker bridge network.
> * **Static IP persistence**: We allocate a **Standard SKU Public IP Address** with static allocation to ensure that the server IP is persistent across VM restarts, making configuration management via Ansible fully reproducible and stable.

---

## Quick Start Guide

### 1. Prerequisites
* **Azure CLI**: Install and log into your Azure account:
  ```bash
  az login
  ```
* **SSH Key**: Ensure an SSH public key is available on your local system (default path: `~/.ssh/id_rsa.pub`).

### 2. Initialization
Prepare the workspace by downloading the necessary providers:
```bash
terraform init
```

### 3. Execution Plan
Review the resources that Terraform will create:
```bash
terraform plan
```
> [!TIP]
> You can override default parameters at command line runtime using the `-var` flag:
> ```bash
> terraform plan -var="ssh_source_address_prefix=<YOUR_IP_CIDR>"
> ```

### 4. Apply Changes
Apply the plan to provision all virtual resources on Azure:
```bash
terraform apply
```
*(Enter `yes` to confirm the execution).*

### 5. Outputs & Next Steps
Upon successful application, copy the output values to feed your Ansible configuration script:
* **`vm_public_ip_address`**: Dedicated target IP.
* **`vm_ssh_connection_string`**: Convenient command to immediately shell into the machine.

### 6. Resource Destruction
To cleanly tear down all provisioned resources and prevent unintended cloud charges:
```bash
terraform destroy
```
