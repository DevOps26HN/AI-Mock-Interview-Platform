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
> If the infrastructure is completely destroyed and recreated via Terraform, the operator must update these links with the new CLI outputs.

* **Frontend Access**: [http://4.223.67.81:3000](http://4.223.67.81:3000)
* **SSH Management**: `ssh azureuser@4.223.67.81`

---

## Repository Structure

| Folder               | Description                                                               |
| -------------------- | ------------------------------------------------------------------------- |
| `client/`            | React + Vite frontend application                                         |
| `server/`            | Spring Boot REST API (interview question service)                         |
| `terraform/`         | Production-grade Terraform configurations for provisioning Azure VM       |
| `infra/`             | Infrastructure configuration                                              |
| `.github/workflows/` | CI/CD workflows                                                           |
| `docker-compose.yml` | Orchestrates the full system (Client, Server, DB)                         |
| `.env.example`       | Template for environment variables                                        |
| `README.md`          | Project overview, setup instructions, and repository structure            |

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
