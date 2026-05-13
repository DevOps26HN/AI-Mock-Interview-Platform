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

| Folder | Description |
|--------|-------------|
| `client/` | React + Vite frontend application |
| `server/` | Spring Boot REST API (interview question service) |
| `infra/` | Infrastructure configuration (planned) |
| `README.md` | Project overview, local setup, repository structure, and team information |

---

## Local Setup

### Prerequisites

| Tool | Minimum Version |
|------|----------------|
| Java | 17 |
| Node.js | 18 |
| npm | 9 |

### Backend Setup

```bash
cd server
./mvnw spring-boot:run
```

Runs at `http://localhost:8080`

### Frontend Setup

Create the environment file first:

```bash
cd client
cp .env.example .env
```

`.env.example`:
```
VITE_API_BASE_URL=http://localhost:8080
```

Then install and start:

```bash
npm install
npm run dev
```

Runs at `http://localhost:5173`

---

## REST Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/interview/questions` | Returns all interview questions |

---

## Team

| Name | GitHub | Primary Subsystem |
|------|--------|-------------------|
| Thanawan Panapongpaisan | [@suisuiss](https://github.com/suisuiss) | AI Component |
| Yong-Tien Wu | [@lennawy](https://github.com/lennawy) | Server |
| Han Hu | [@huhan606](https://github.com/huhan606) | Client |