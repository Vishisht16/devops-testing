# GKE Pipeline Template 🚀

![Google Cloud](https://img.shields.io/badge/GoogleCloud-%234285F4.svg?style=flat&logo=google-cloud&logoColor=white)
![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=flat&logo=terraform&logoColor=white)
![Prometheus](https://img.shields.io/badge/Prometheus-E6522C?style=flat&logo=Prometheus&logoColor=white)
![License: Unlicense](https://img.shields.io/badge/license-Unlicense-blue.svg)

A complete DevOps template for deploying a lightweight, auto-scaling Python/Redis application on Google Kubernetes Engine (GKE). This repository serves as a reference implementation for Infrastructure as Code (IaC), DevSecOps pipelines, and Observability stacks.

> **Personal Note:** This project started as a learning experiment to understand the "Why" behind DevOps tools. It evolved from running a simple Docker container locally to architecting a self-healing, multi-layer auto-scaling infrastructure managed entirely via code.

*Note: This repository is a Template. You can use this codebase to bootstrap your own GKE-based projects with pre-configured CI/CD and security scanning.*

## 🏗️ Architecture & Tech Stack
 
This project leverages a lightweight, security-focused stack: 

- **Application Layer:**
  - **API:** Python 3.12 (Alpine 3.23) - Optimized for minimal footprint.
  - **State:** Redis (Alpine) - High-performance in-memory datastore.
- **Infrastructure:**
  - **Cloud:** Google Cloud Platform (GCP).
  - **Orchestration:** Google Kubernetes Engine (GKE) Standard Cluster.
  - **IaC:** Terraform (State-managed infrastructure provisioning).
- **Observability:**
  - **Monitoring:** Prometheus & Grafana (Deployed via Helm) for cluster metrics.
- **Pipeline & Security:**
  - **CI/CD:** GitHub Actions (Automated Build -> Scan -> Deploy).
  - **Security:** Aqua Security Trivy (Container Vulnerability Scanning).
  - **Registry:** Google Artifact Registry.
- **Scalability (Dual-Layer):**
  - **Pod Level:** HPA (Horizontal Pod Autoscaler) based on CPU utilization metrics.
  - **Node Level:** Cluster Autoscaler (Infrastructure scaling).

## ⚙️ Setup & Prerequisites

Before deploying, ensure you have the following prerequisites configured in your Google Cloud Project.

### 1. Enable Required APIs
Run the following command in your local terminal (or Cloud Shell) to enable necessary GCP services:

```bash
gcloud services enable \
  container.googleapis.com \
  artifactregistry.googleapis.com \
  iam.googleapis.com \
  compute.googleapis.com
```

### 2. Configure GitHub Secrets
Go to **Settings > Secrets and variables > Actions** in your repository and add:

| Secret Name | Description | Value / Command to Generate |
| :--- | :--- | :--- |
| `GCP_PROJECT_ID` | Your Google Cloud Project ID | From GCP Dashboard |
| `GCP_SA_KEY` | Service Account JSON Key | **Role Required:** `Editor` (for simplicity) or (`Kubernetes Engine Admin` + `Artifact Registry Admin` + `Service Account User`) |
| `REDIS_PASSWORD` | Secure Password for Redis | Any secure string (e.g., run: `openssl rand -base64 20` |

## ✨ Key Features

### 1. Zero-Touch Deployment & Security
- **Automated Pipeline:** The pipeline is fully automated. Pushing to main triggers Terraform validation, Docker builds, and Kubernetes rollouts without manual intervention.
- **Traceability:** Uses `sed` for dynamic image tagging with Git Commit SHA to ensure traceability.

### 2. Deep Observability & Monitoring
- **Pre-configured Stack:** The observability stack deploys **Prometheus** and **Grafana** via Helm as dedicated Kubernetes workloads for cluster-level monitoring.
- **Metrics:** Provides real-time visibility into CPU, memory, and resource utilization at the pod and node level, enabling monitoring and capacity analysis.

### 3. DevSecOps Integration
- **Vulnerability Scanning:** Integrated **Trivy** to scan Docker images for `CRITICAL` vulnerabilities.
- **Deployment Halt:** The pipeline automatically blocks deployment if high-severity CVEs are detected, preventing insecure artifacts from reaching production.

### 4. Multi-Layer Auto-Scaling
- **Horizontal Pod Autoscaler (HPA):** Automatically scales application pods from 2 to 10 based on CPU utilization metrics.
- **Cluster Autoscaler:** Automatically provisions new compute nodes (VMs) when the cluster runs out of resources, scaling from 1 to 3 nodes dynamically.

### 5. Security & Networking
- **Isolation:** Redis is exposed only internally via `ClusterIP`, ensuring no external access to the database.
- **Traffic Routing:** Uses **Google Cloud Load Balancer** for production-grade external traffic management.

### 6. Resilience & Optimization
- **Persistence:** Configured **Persistent Volume Claims (PVC)** to ensure Redis data persistence across pod restarts and stateful workload considerations in Kubernetes.
- **Efficient Builds:** Uses multi-stage Docker builds with **Alpine Linux** base images to keep attack surfaces small and pull times fast.

### 7. Terraform State Management

- **Local State Management:** For this template, Terraform was executed locally during development, and the state file is managed locally by Terraform. This approach keeps the setup simple and beginner-friendly for learning and experimentation.  
- **Production Requirement:** In a production environment, the Terraform state should be stored in a remote backend (e.g., Google Cloud Storage with state locking) to enable team collaboration and prevent state corruption.

## 🛠️ How it Works

The pipeline follows this workflow:
1. Code push to `main` triggers GitHub Actions.
2. Terraform validates the infrastructure state.
3. Docker image is built and tagged with Git SHA.
4. Built image is scanned by Trivy.
5. If secure, image is pushed to Google Artifact Registry.
6. Kubernetes rollout to GKE is updated with the new image tag.
7. HPA monitors load and scales pods automatically.

## 📜 License

This project is released under the **The Unlicense**. You are free to copy, modify, publish, use, compile, sell, or distribute this software, either in source code form or as a compiled binary, for any purpose, commercial or non-commercial, and by any means.

---
*Developed as a cloud-native learning initiative by **Vishisht Mishra**.*
