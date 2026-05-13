# AI Mock Interview Platform

## Overview

AI Mock Interview Platform is a team project that helps users practice technical interviews through AI-generated mock interview sessions. Users are presented with AI-curated
interview questionsallowing them to simulate
realistic interview conditions and identify skill gaps before the real thing. The platform
is built on a cloud-native microservice architecture: a React frontend communicates with a
Spring Boot REST backend, with a dedicated AI service planned for dynamic question
generation and answer feedback.

---

## Local Setup

### Prerequisites

| Tool | Minimum Version |
|------|----------------|
| Java | 17 |
| Node.js | 18 |
| npm | 9 |

### Backend Setup

## Run Backend Service

```bash
cd server
./mvnw spring-boot:run
```

Backend runs at:

```text
http://localhost:8080
```

---

### Frontend Setup

##Create the environment file first:

```bash
cd client
cp .env.example .env
```

`.env.example`:

## Run Client Application

```bash
cd client
npm install
npm run dev
```

Client runs at:

```text
http://localhost:5173
```

---

# Implemented REST Endpoint

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/interview/questions` | Returns all interview questions |

---

## Repository Structure

| Folder | Description |
|--------|-------------|
| `client/` | React + Vite frontend application |
| `server/` | Spring Boot REST API (backend service) |
| `infra/` | Infrastructure configuration |
| `README.md` | Project overview, setup, and team information |

---

## Team Members

| Name | GitHub | Primary Subsystem |
|------|--------|-------------------|
| Thanawan Panapongpaisan | [@suisuiss](https://github.com/suisuiss) | AI Component |
| Yong-Tien Wu | [@lennawy](https://github.com/lennawy) | Server |
| Han Hu | [@huhan606](https://github.com/huhan606) | Client |