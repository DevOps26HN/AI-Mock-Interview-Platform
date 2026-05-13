# AI Mock Interview Platform

AI Mock Interview Platform is a team project that helps users practice technical interviews through AI-generated mock interview sessions.

The platform is designed with a cloud-native microservice architecture consisting of a Spring Boot backend, a frontend client application, and a future AI service for question generation and feedback.

---

# Repository Structure

```text
AI-Mock-Interview-Platform/
├── client/                 # Frontend application
├── server/                 # Spring Boot backend service
├── infra/                  # Infrastructure configuration
└── README.md
```

---

# Backend Setup

## Requirements

- Java 17+

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

# Implemented REST Endpoint

```text
GET /api/interview/questions
```

Example:

```text
http://localhost:8080/api/interview/questions
```

---

# Git Workflow



---

# Team Members

| Name | GitHub Username | Primary Subsystem |
|---|---|---|
| Thanawan Panapongpaisan | suisuiss | AI Component |
| Yong-Tien Wu | lennawy | Server |
| Han Hu | huhan606 | Client |
