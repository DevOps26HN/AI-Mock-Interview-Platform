# Ansible VM Configuration and Deployment

This directory contains the Ansible playbooks and templates required to take a bare Linux (Ubuntu 22.04 LTS) VM provisioned by Terraform from a basic OS to a running, secure, containerized deployment of the **Mock Interview Platform**.

## Security and Secret Handling

To comply with strict security requirements, **no actual credentials, keys, or active host configurations are committed to this repository**. 
- The active `inventory.ini` and `vars.yml` files are ignored by git via [.gitignore](../.gitignore).
- A local Jinja2 template is used to dynamically inject configurations into the VM, maintaining complete confidentiality of production databases and host endpoints.

---

## Directory Structure

```text
ansible/
├── templates/
│   └── .env.j2          # Jinja2 environment variables template for Docker Compose
├── inventory.ini.example # Template defining host target and SSH parameters
├── vars.yml.example      # Template defining database credentials and application variables
├── playbook.yml          # Main deployment and configuration playbook
└── README.md             # This documentation file
```

---

## Step-by-Step Deployment Instructions

### Step 1: Provision the Infrastructure with Terraform
First, ensure that your infrastructure is active on Azure.
1. Navigate to the `terraform/` directory:
   ```bash
   cd terraform
   ```
2. Initialize and deploy:
   ```bash
   terraform init
   terraform apply
   ```
3. Take note of the output variable `vm_public_ip_address` printed to the terminal.

---

### Step 2: Prepare Ansible Local Files
Before executing the playbook, create local configurations containing your active host and credentials.
1. Copy the example templates inside this directory:
   ```bash
   cp inventory.ini.example inventory.ini
   cp vars.yml.example vars.yml
   ```
2. Configure **`inventory.ini`**: Replace `YOUR_VM_PUBLIC_IP` with the public IP address obtained from the Terraform output:
   ```ini
   [webservers]
   interview_vm ansible_host=<YOUR_VM_PUBLIC_IP> ansible_user=azureuser ansible_ssh_private_key_file=~/.ssh/id_rsa
   ```
3. Configure **`vars.yml`**: Define your custom secure credentials:
   ```yaml
   db_name: "interview_db"
   db_user: "postgres"
   db_password: "MySuperSecurePassword123!"  # Keep this secret
   ```

---

### Step 3: Run the Ansible Playbook
Execute the playbook from this directory to build and launch the platform:
```bash
ansible-playbook -i inventory.ini playbook.yml
```

#### What this playbook does:
1. Installs all Docker system dependencies and requirements on the remote VM.
2. Configures Docker's official stable repository and GPG keys.
3. Installs Docker CE, CLI, and the native `docker-compose-plugin` (providing standard `docker compose` command).
4. Adds the admin SSH user to the `docker` system group for non-sudo operation.
5. Synchronizes the root `docker-compose.yml`, backend `server/`, and frontend `client/` directories to `/home/azureuser/app` on the VM.
6. Dynamically renders the `.env` configuration file using your local parameters and the VM's active public IP address for `VITE_API_URL`.
7. Builds, recreates, and starts all system containers (`interview-db`, `interview-server`, and `interview-client`) in the background.
8. Verifies container health and outputs the final status mapping.

---

## Accessing the Platform

Once the playbook successfully finishes execution, the application will be reachable at:
- **Web Frontend**: `http://<YOUR_VM_PUBLIC_IP>:3000`
- **Backend API**: `http://<YOUR_VM_PUBLIC_IP>:8080`

### Idempotency
This playbook is 100% **idempotent**. Running the command a second time:
```bash
ansible-playbook -i inventory.ini playbook.yml
```
Will verify that all software is up to date and that containers are healthy. It will make no modifications or disruptions to your active deployment unless local code changes or configuration updates are detected, at which point Docker will rebuild and recreate only the updated services.
