# 1. Provider (Which cloud provider are we using?)
# We are telling Terraform that we will use Google Cloud
provider "google" {
  project = var.project_id # GCP Project ID
  region  = var.region     # Server location (Iowa)
  zone    = var.zone
}

# We also need the Helm provider to deploy applications to our GKE cluster
data "google_client_config" "default" {}

provider "helm" {
  kubernetes {
    host                   = "https://${google_container_cluster.primary.endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
  }
}

# 2. Resource (What resource are we creating?)
# Syntax: resource "type_of_resource" "resource_name"

resource "google_service_account" "default" {
  account_id   = var.service_account_id
  display_name = var.service_account_display_name
}

resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.zone

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1
  deletion_protection      = false
}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  name       = var.node_pool_name
  location   = var.zone
  cluster    = google_container_cluster.primary.name
  initial_node_count = var.initial_node_count

  autoscaling {
    min_node_count = var.min_node_count
    max_node_count = var.max_node_count
  }

  lifecycle {
    ignore_changes = [
      initial_node_count
    ]
  }

  node_config {
    preemptible  = var.preemptible
    machine_type = var.machine_type

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = google_service_account.default.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}

resource "google_artifact_registry_repository" "docker_repo" {
  location      = var.region
  repository_id = "devops-store"
  description   = "Docker repository for DevOps store application"
  format        = "DOCKER"
}

resource "google_project_iam_member" "node_artifact_registry_reader" {
  project = var.project_id
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_service_account.default.email}"
}

resource "helm_release" "prometheus_stack" {
  name       = "monitoring"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = "default"

  # We need to ensure that the node pool is created before we try to deploy the Helm chart, since the chart will create Kubernetes resources that require a working cluster.
  depends_on = [google_container_node_pool.primary_preemptible_nodes]
}