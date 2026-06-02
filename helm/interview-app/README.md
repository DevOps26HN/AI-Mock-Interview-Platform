# AI Mock Interview Platform Helm Chart

This Helm chart deploys the **AI Mock Interview Platform** in a Kubernetes cluster (optimized for the TUM K8s cluster environment). It provisions the React frontend client, Spring Boot backend server, and a persistent PostgreSQL database.

## Prerequisites

- **Kubernetes 1.22+**
- **Helm 3.0+**
- **TUM ID (`tumid`)**: Required for deployment identification and policy validation.
- **OpenAI API Key (`server.openaiApiKey`)**: Required at deployment time. The installation will fail early if not provided.

---

## Configuration Parameters

The following table lists the configurable parameters of the chart and their default values:

| Parameter | Description | Default | Required |
| --- | --- | --- | --- |
| `tumid` | Your TUM student ID (e.g., `go46rol`) | `""` | **Yes** |
| `server.openaiApiKey` | Your OpenAI API secret key | `""` | **Yes** |
| `server.replicaCount` | Number of backend server replicas | `1` | No |
| `server.image.repository` | Docker image repository for the backend server | `ghcr.io/devops26hn/ai-mock-interview-platform/server` | No |
| `server.image.tag` | Docker image tag for the backend server | `latest` | No |
| `server.service.port` | Port exposed by the backend service | `8080` | No |
| `database.name` | Name of the PostgreSQL database | `interview_db` | No |
| `database.username` | PostgreSQL administrator username | `postgres` | No |
| `database.password` | PostgreSQL administrator password | `postgres` | No |
| `database.storageSize` | Persistent volume claim size for the database | `1Gi` | No |
| `client.replicaCount` | Number of frontend client replicas | `1` | No |
| `client.image.repository` | Docker image repository for the frontend client | `ghcr.io/devops26hn/ai-mock-interview-platform/client` | No |
| `client.image.tag` | Docker image tag for the frontend client | `latest` | No |
| `client.service.port` | Port exposed by the frontend service | `3000` | No |
| `ingress.enabled` | Enable Ingress routing rule | `true` | No |
| `ingress.className` | Ingress class controller to use | `nginx` | No |
| `ingress.tls` | Enable TLS termination for the domain | `true` | No |

---

## Quickstart

### 1. Installation

To deploy the platform with your custom credentials:

```bash
helm upgrade --install ai-interview ./helm/interview-app \
  --namespace ai-mock-interview \
  --set tumid="YOUR_TUM_ID" \
  --set server.openaiApiKey="YOUR_OPENAI_API_KEY"
```

### 2. Verification

Check if all pods, services, and Persistent Volume Claims (PVC) are running successfully:

```bash
kubectl get all -n ai-mock-interview
kubectl get pvc -n ai-mock-interview
```

### 3. Accessing the Application

Once the ingress is active, access the platform via the configured ingress host:
`https://ai-mock-interview-ss26.stud.k8s.aet.cit.tum.de`

---

## Uninstallation

To uninstall and purge the deployment:

```bash
helm uninstall ai-interview --namespace ai-mock-interview
```

> [!WARNING]
> Uninstalling the Helm release will delete all associated resources, including the `PersistentVolumeClaim`. If you wish to retain the database volume, make sure to back up your data or set appropriate reclaim policies on the Persistent Volume.

---

## Troubleshooting

### 1. Missing Required Keys during Install
If you see errors like:
```text
Error: execution error at (interview-app/templates/deployment.yaml:1:4): ERROR: Your TUM ID ('tumid') is not set...
```
or
```text
Error: server.openaiApiKey is required. Please set server.openaiApiKey...
```
You must supply them explicitly using `--set` or within a private `values.yaml` file.

### 2. Backend fails with Port Conflict (NumberFormatException)
If the backend crashes with `java.lang.NumberFormatException: For input string: "tcp://..."`, this is resolved in this version of the chart by overriding `SERVER_PORT: "8080"` directly in the container env, bypassing Kubernetes' automatic Service environment injection mechanism.

### 3. Backend fails to connect to database (SocketTimeoutException)
If the backend reports `Connect timed out`, ensure the `db` service is up and running. In this chart, we deploy a local PostgreSQL database Service and Pod automatically. If you use an external database, update the `DB_HOST` in your values file to point to your external database service.
