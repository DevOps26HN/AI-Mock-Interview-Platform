# AI Mock Interview Platform

## Overview

The AI Mock Interview Platform is a web application designed to help software engineering
candidates prepare for technical job interviews. Users are presented with AI-curated
interview questions allowing them to simulate
realistic interview conditions and identify skill gaps before the real thing.

---

## Live Application URL (Active for Evaluation Window)

> [!NOTE]
> The Public IP is provisioned using **Static Standard SKU** to ensure persistency during the grading window. 

* **Frontend Access**: [https://ai-mock-interview-ss26.stud.k8s.aet.cit.tum.de](https://ai-mock-interview-ss26.stud.k8s.aet.cit.tum.de)
* The application is deployed on the AET Kubernetes Cluster using Helm. 

---

## Repository Structure

| Folder               | Description                                                               |
| -------------------- | ------------------------------------------------------------------------- |
| `client/`            | React + Vite frontend application                                         |
| `server/`            | Spring Boot REST API (interview question service)                         |
| `helm/`              | Helm chart for Kubernetes deployment on the AET Cluster                   |
| `terraform/`         | Production-grade Terraform configurations for provisioning Azure VM       |
| `ansible/`           | Ansible playbooks for VM configuration and application deployment         |
| `infra/`             | Infrastructure configuration                                              |
| `.github/workflows/` | CI/CD workflows                                                           |
| `docker-compose.yml` | Orchestrates the full system (Client, Server, DB)                         |
| `.env.example`       | Template for environment variables                                        |
| `README.md`          | Project overview, setup instructions, and repository structure            |

---
## Infrastructure Automation (Terraform)

Terraform configurations are provided under the `terraform/` directory to provision the Azure infrastructure for the AI Mock Interview Platform.

The setup includes:

- Azure Linux Virtual Machine
- Virtual Network & Network Security Group (NSG)
- Static Public IP allocation
- Secure inbound firewall rules for required application ports

### Prerequisites

- Terraform
- Azure CLI
- Azure Subscription
- SSH public key (`~/.ssh/id_rsa.pub` by default)

Login to Azure before provisioning:

```bash
az login
```
### Provision Infrastructure

Initialize Terraform providers:

```bash
cd terraform
terraform init
```

Review the execution plan:

```bash
terraform plan
```

Provision the Azure resources:

```bash
terraform apply
```

Terraform will output:

- `vm_public_ip_address`
- `vm_ssh_connection_string`

These values are later used for the Ansible deployment workflow.

### Destroy Infrastructure

To remove all provisioned resources:

```bash
terraform destroy
```

### Security Notes

- Sensitive local configuration files are excluded from version control.
- Infrastructure parameters are externalized through Terraform variables.
- Only required public ports are exposed through the Azure NSG.

---

## Cloud Deployment (Ansible)

Once the Azure VM is provisioned via Terraform, use Ansible to configure the bare OS, install Docker, and deploy the application.

### Secret and Configuration Handling
To ensure no credentials are committed to the repository, we use localized configuration files ignored by Git (`.gitignore`).

1. **Prepare Configuration Files**:
   Navigate to the `ansible/` directory and create local copies of the templates:
   ```bash
   cd ansible
   cp inventory.ini.example inventory.ini
   cp vars.yml.example vars.yml
   ```
2. **Set Environment Variables (No secrets in Git)**:
   *   Edit `inventory.ini`: Replace `YOUR_VM_PUBLIC_IP` with the public IP of your provisioned VM.
   *   Edit `vars.yml`: Provide secure values for your database credentials (`db_name`, `db_user`, `db_password`).

### Deployment Command
Run the idempotent Ansible playbook to completely configure the VM and start the platform:
```bash
ansible-playbook -i inventory.ini playbook.yml
```

---

## Kubernetes Deployment (Helm)

The AI Mock Interview Platform is deployed on the AET Kubernetes Cluster using Helm.

The Helm chart packages the complete application stack, including:

- React frontend
- Spring Boot backend
- PostgreSQL database
- Kubernetes Services
- ConfigMaps
- Ingress routing

All deployment-specific configuration is externalized through Helm values to ensure reproducible and consistent deployments across environments.

### Prerequisites

Before deploying, ensure that:

- Helm is installed
- kubectl is installed
- You have access to the AET Kubernetes Cluster
- A valid kubeconfig file is available locally

### Deploy the Application

Step 1: Configure cluster access:

```bash
export KUBECONFIG=/path/to/kubeconfig.yaml
```

Step 2: Create the namespace:

```bash
kubectl create namespace <YOUR_TUM_ID>-devops26
```

Step 3: Create the database secret:

```bash
kubectl create secret generic interview-db-secrets \
  --from-literal=username=postgres \
  --from-literal=password=<YOUR_PASSWORD> \
  --namespace <YOUR_TUM_ID>-devops26
```

Step 4: Create the GitHub Container Registry secret:

```bash
kubectl create secret docker-registry ghcr-secret \
  --docker-server=ghcr.io \
  --docker-username=<YOUR_GITHUB_USERNAME> \
  --docker-password=<YOUR_GITHUB_PAT> \
  --namespace <YOUR_TUM_ID>-devops26
```

Step 5: Install or upgrade the release:

```bash
helm upgrade --install interview-app ./helm/interview-app \
  --namespace <YOUR_TUM_ID>-devops26 \
  --set tumid="<YOUR_TUM_ID>"
```

### Validation (Optional)

Verify the Helm chart structure and syntax:

```bash
helm lint ./helm/interview-app --set tumid="<YOUR_TUM_ID>"
```

Render the Kubernetes manifests locally before deployment:

```bash
helm template interview-app ./helm/interview-app \
  --set tumid="<YOUR_TUM_ID>"
```

### Public Access

The application hostname is generated automatically from the operator's TUM ID. 

After deployment, the application will be available at:

```text
https://ai-mock-interview-<YOUR_TUM_ID>.stud.k8s.aet.cit.tum.de
```

Example:

```text
TUM ID: ab12cde
URL: https://ai-mock-interview-ab12cde.stud.k8s.aet.cit.tum.de
```

Each deployment receives its own hostname and does not share the URL of other deployments.

### Remove the Deployment

The release can be removed with:

```bash
helm uninstall interview-app \
  --namespace <YOUR_TUM_ID>-devops26
```

### Security Notes

- Kubernetes credentials are not stored in the repository.
- Application secrets are managed through Kubernetes Secrets.
- Registry credentials remain external to source control.
- No cluster access tokens or kubeconfig files are committed to Git.

---

## Quick Start (Docker)

The full system can be brought up with a single command from a clean clone:

```bash
# Copy environment variables template
cp .env.example .env

# Start all services
docker compose up --build
```

The services will be available at: http://localhost:3000

### Exposed Ports

| Component | Host Port | Internal Port |
| --------- | --------- | ------------- |
| Client    | 3000      | 80            |
| Server    | 8080      | 8080          |
| Database  | 5432      | 5432          |

---

## Environment Variables

The project uses a `.env` file for configuration. Sane defaults are provided in `.env.example`.

| Variable            | Default Value       | Description                                      |
| ------------------- | ------------------- | ------------------------------------------------ |
| `DB_HOST`           | `db`                | Database hostname (service name in compose)      |
| `DB_PORT`           | `5432`              | Database port                                    |
| `DB_NAME`           | `interview_db`      | Name of the PostgreSQL database                  |
| `DB_USERNAME`       | `postgres`          | Database username                                |
| `DB_PASSWORD`       | `postgres`          | Database password                                |
| `POSTGRES_DB`       | `interview_db`      | DB name for PostgreSQL container initialization |
| `POSTGRES_USER`     | `postgres`          | DB user for PostgreSQL container initialization |
| `POSTGRES_PASSWORD` | `postgres`          | DB password for PostgreSQL container init       |
| `VITE_API_URL`      | `http://localhost:8080` | URL of the backend API for the client        |

---

## Local Development (Without Docker)

### Prerequisites

| Tool    | Minimum Version |
| ------- | --------------- |
| Java    | 21 or newer     |
| Node.js | 22 or newer     |
| npm     | 9 or newer      | 
| Postgres| 16              |

### Backend Setup

Ensure you have a PostgreSQL database running locally and matching the configuration in `server/src/main/resources/application.yaml`.

```bash
cd server
./mvnw spring-boot:run
```

Runs at `http://localhost:8080`

### Frontend Setup

```bash
cd client
npm install
npm run dev
```

Runs at `http://localhost:5173`

---

## REST Endpoints

| Method | Path                       | Description                     |
| ------ | -------------------------- | ------------------------------- |
| GET    | `/api/interview/questions` | Returns all interview questions |

---

## Git Workflow

- Create a dedicated feature branch for each task or feature.
- Do not push directly to the `main` branch.
- Open a Pull Request (PR) for every completed feature or change.
- All team members must review and approve the PR before merging.
- Test the application locally before approving or merging changes.
- Delete merged feature branches to keep the repository clean and organized.

---

## Team

| Name                    | GitHub                                   | Primary Subsystem |
| ----------------------- | ---------------------------------------- | ----------------- |
| Thanawan Panapongpaisan | [@suisuiss](https://github.com/suisuiss) | AI Component      |
| Yong-Tien Wu            | [@lennawy](https://github.com/lennawy)   | Server            |
| Han Hu                  | [@huhan606](https://github.com/huhan606) | Client            |
