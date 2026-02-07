variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region for resources"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "The GCP zone for resources"
  type        = string
  default     = "us-central1-a"
}

variable "cluster_name" {
  description = "The name of the GKE cluster"
  type        = string
  default     = "devops-cluster"
}

variable "node_pool_name" {
  description = "The name of the node pool"
  type        = string
  default     = "my-node-pool"
}

variable "service_account_id" {
  description = "The service account ID"
  type        = string
  default     = "devops-service-account"
}

variable "service_account_display_name" {
  description = "The service account display name"
  type        = string
  default     = "DevOps Service Account"
}

variable "machine_type" {
  description = "The machine type for node pool"
  type        = string
  default     = "e2-standard-2"
}

variable "node_count" {
  description = "Number of nodes in the node pool"
  type        = number
  default     = 1
}

variable "preemptible" {
  description = "Whether to use preemptible nodes"
  type        = bool
  default     = true
}
