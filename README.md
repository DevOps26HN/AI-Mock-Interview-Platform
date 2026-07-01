# AI Mock Interview Platform

## Overview

The AI Mock Interview Platform is a web application designed to help software engineering
candidates prepare for technical job interviews. Users are presented with AI-curated
interview questions allowing them to simulate realistic interview conditions and identify skill gaps before the real thing.

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
| `genai/`             | FastAPI-based GenAI microservice                                          |
| `helm/`              | Helm chart for Kubernetes deployment on the AET Cluster                   |
| `terraform/`         | Production-grade Terraform configurations for provisioning Azure VM       |
| `ansible/`           | Ansible playbooks for VM configuration and application deployment         |
| `infra/`             | Infrastructure configuration                                              |
| `monitoring/`        | Prometheus alerts and Grafana dashboard configurations                    |
| `.github/workflows/` | CI/CD workflows                                                           |
| `docker-compose.yml` | Orchestrates the full system (Client, Server, GenAI, DB)                  |
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

## GenAI Service

The platform includes a dedicated FastAPI-based GenAI microservice that acts as the AI layer of the system. It currently generates contextual hints for interview questions and provides a foundation for future capabilities such as AI-generated questions, answer evaluation, and interview feedback.

> [!NOTE]
> For a detailed architectural overview, API endpoints, resilient fallback flows, local development setup, and observability testing instructions, see the [GenAI Microservice README](genai/README.md).

### Supported Backends

The GenAI service supports two inference modes:

| Backend  | Description                        |
|----------|------------------------------------|
| gemini   | Uses Google's Gemini API           |
| local    | Uses a locally hosted Ollama model |

The active backend is selected through:

```bash
GENAI_BACKEND=gemini
```

or

```bash
GENAI_BACKEND=local
```

### Fallback Strategy

When `GENAI_BACKEND=gemini`, the service follows a resilient fallback chain: 

1. Gemini API
2. Local Ollama model
3. Simulated fallback hint

When `GENAI_BACKEND=local`, Ollama is the sole backend — if it is unreachable, the service returns 503.

---

## Observability & Monitoring

To ensure reliability, track request latency, and monitor the AI fallback mechanisms, the platform integrates a complete observability stack consisting of **Prometheus** and **Grafana**.

### 1. Telemetry & Metrics
* **Outbound Call Tracking (Server)**: The Spring Boot server measures request count, HTTP status codes, and latency (`http_client_requests_seconds`) when calling the GenAI microservice.
* **Microservice Traffic Tracking (GenAI)**: The FastAPI service captures incoming request rates, error responses (5xx), and duration via `prometheus_fastapi_instrumentator`.
* **Fallback & Backend Routing (GenAI)**: A custom counter metric `genai_requests_total` is partitioned by `backend` (configured backend) and `source` (`gemini`, `local` fallback, or `simulated` fallback) to track fallback occurrences.

### 2. Alerting Configurations
Prometheus is configured with alert rules under [alerts.yml](monitoring/prometheus/alerts.yml):
* **`GenaiDown`**: Critical alert triggered if the GenAI container goes offline (`up{job="genai"} == 0` for 30s).
* **`GenaiHighErrorRate`**: Warning alert triggered if GenAI 5xx errors exceed 10% of total requests inside a 5-minute window (`for: 1m`).

### 3. Grafana Dashboards
A custom Grafana dashboard (**AI Mock Interview Platform Observability**) is provisioned under `monitoring/grafana/` to visualize:
* **GenAI Inference & Fallback Source Distribution** (`genai_requests_total` split by backend/source).
* **GenAI Total Requests**, **Error Rate**, and **Average Latency**.

> [!TIP]
> For instructions on how to simulate and verify these alerts locally or on the AET Kubernetes cluster, see the **Testing & Verification** section in the [GenAI Microservice README](genai/README.md).

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
- GenAI FastAPI microservice

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

Step 4: Create the GenAI secret:

```bash
kubectl create secret generic genai-secrets \
  --from-literal=GEMINI_API_KEY=<YOUR_API_KEY> \
  --namespace <YOUR_TUM_ID>-devops26
```

Step 5: Create the GitHub Container Registry secret:

```bash
kubectl create secret docker-registry ghcr-secret \
  --docker-server=ghcr.io \
  --docker-username=<YOUR_GITHUB_USERNAME> \
  --docker-password=<YOUR_GITHUB_PAT> \
  --namespace <YOUR_TUM_ID>-devops26
```

Step 6: Install or upgrade the release:

```bash
helm upgrade --install interview-app ./helm/interview-app \
  --namespace <YOUR_TUM_ID>-devops26 \
  --set tumid="<YOUR_TUM_ID>"
```

### Validation (Optional)

Verify the Helm chart structure and syntax:

```bash
helm lint ./helm/interview-app \
  --set tumid="<YOUR_TUM_ID>"
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
This starts the complete application stack:

- React frontend (http://localhost:3000)
- Spring Boot backend (http://localhost:8080)
- GenAI FastAPI service (http://localhost:8000)
- PostgreSQL database (localhost:5432)
- Prometheus (http://localhost:9090)
- Grafana (http://localhost:3001)

The frontend application is accessible at: http://localhost:3000

### Using Gemini

Edit `.env`:

```env
GENAI_BACKEND=gemini
GEMINI_API_KEY=<YOUR_API_KEY>
```

### Using Local Models (Ollama)

```env
GENAI_BACKEND=local
LOCAL_MODEL_URL=http://host.docker.internal:11434/api/generate
```

### Exposed Ports

| Component  | Host Port   | Internal Port | Description |
| ---------- | ----------- | ------------- | ----------- |
| Client     | 3000        | 80            | React Frontend application |
| Server     | 8080        | 8080          | Spring Boot REST API |
| GenAI      | not exposed | 8000          | FastAPI GenAI Microservice |
| Database   | 5432        | 5432          | PostgreSQL Database |
| Prometheus | 9090        | 9090          | Prometheus Time Series DB |
| Grafana    | 3001        | 3000          | Grafana Dashboards |

---

## Environment Variables

The project uses a `.env` file for configuration. Sane defaults are provided in `.env.example`.

| Variable            | Default Value           | Description                                      |
| ------------------- | -------------------     | ------------------------------------------------ |
| `DB_HOST`           | `db`                    | Database hostname (service name in compose)      |
| `DB_PORT`           | `5432`                  | Database port                                    |
| `DB_NAME`           | `interview_db`          | Name of the PostgreSQL database                  |
| `DB_USERNAME`       | `postgres`              | Database username                                |
| `DB_PASSWORD`       | `postgres`              | Database password                                |
| `POSTGRES_DB`       | `interview_db`          | DB name for PostgreSQL container initialization  |
| `POSTGRES_USER`     | `postgres`              | DB user for PostgreSQL container initialization  |
| `POSTGRES_PASSWORD` | `postgres`              | DB password for PostgreSQL container init        |
| `VITE_API_URL`      | `http://localhost:8080` | URL of the backend API for the client        |
| `GEMINI_API_KEY`    | `empty`                 | Gemini API key used when GENAI_BACKEND=gemini    |
| `GENAI_BACKEND`     | `local`                 | Selects the active AI backend (local or gemini)  |
| `LOCAL_MODEL_URL`   | `http://host.docker.internal:11434/api/generate` | Ollama/local model endpoint |
| `GENAI_SERVICE_URL` | `http://genai:8000`     | Internal GenAI service URL                       |

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

When running the backend without Docker, set the GenAI service URL to the locally running GenAI service:

```bash
export GENAI_SERVICE_URL=http://localhost:8000
```

```bash
cd server
./mvnw spring-boot:run
```

Runs at `http://localhost:8080`

---

### Frontend Setup

```bash
cd client
npm install
npm run dev
```

Runs at `http://localhost:5173`

---

### GenAI Service Setup

The GenAI service can be started locally from the `genai/` directory.

```bash
cd genai
pip install -r requirements.txt
uvicorn main:app --host 0.0.0.0 --port 8000
```

Runs at `http://localhost:8000`

Health check: 

```bash
curl http://localhost:8000/health
```

---

## REST Endpoints

| Method | Path                                 | Description                                    |
| ------ | ------------------------------------ | ---------------------------------------------- |
| GET    | `/api/interview/questions`           | Returns all interview questions                |
| POST   | `/api/interview/questions/{id}/hint` | Generates an AI hint for the selected question |

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
