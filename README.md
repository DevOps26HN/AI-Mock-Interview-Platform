# AI Mock Interview Platform

## Overview

The AI Mock Interview Platform is a web application designed to help software engineering
candidates prepare for technical job interviews. Users are presented with AI-curated
interview questions allowing them to simulate
realistic interview conditions and identify skill gaps before the real thing. The platform
is built on a cloud-native microservice architecture: a React frontend communicates with a
Spring Boot REST backend, with a dedicated AI service planned for dynamic question
generation and answer feedback.

---

## Repository Structure

| Folder               | Description                                                               |
| -------------------- | ------------------------------------------------------------------------- |
| `client/`            | React + Vite frontend application                                         |
| `server/`            | Spring Boot REST API (interview question service)                         |
| `infra/`             | Infrastructure configuration                                              |
| `.github/workflows/` | CI/CD workflows                                                           |
| `README.md`          | Project overview, local setup, repository structure, and team information |

---

## Setup Guide

### Option 1: Run with Docker (Recommended)

This option allows the application to run without manually installing Java, Maven, Node.js, or npm locally.

### Prerequisites

| Tool | Required Version |
|------|------------------|
| Docker | Latest stable version |

---

### Run the Full System with Docker Compose

The entire system can be started with a single command:
```bash 
docker compose up --build
```

This will automatically start all configured services and containers.

The services will be available at: `http://localhost:5173`

### Option 2: Local Setup
Use this option if you want to run and modify each service locally during development.

### Prerequisites
| Tool    | Required Version |
| ------- | ---------------- |
| Java    | 21 or newer      |
| Node.js | 22 or newer      |
| npm     | 9                |

### Backend Setup

```bash
cd server
./mvnw spring-boot:run
```

Backend runs at `http://localhost:8080`

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
- All team member must review and approve the PR before merging.
- Test the application locally before approving or merging changes.
- Delete merged feature branches to keep the repository clean and organized.

---

## Team Members

| Name                    | GitHub                                   | Primary Subsystem |
| ----------------------- | ---------------------------------------- | ----------------- |
| Thanawan Panapongpaisan | [@suisuiss](https://github.com/suisuiss) | AI Component      |
| Yong-Tien Wu            | [@lennawy](https://github.com/lennawy)   | Server            |
| Han Hu                  | [@huhan606](https://github.com/huhan606) | Client            |

