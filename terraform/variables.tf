variable "project_id" {
  description = "Project ID"
  default     = "blockchain-nodes-2024"
}

variable "region" {
  description = "Region"
  default     = "europe-west1"
}

variable "cluster_name" {
  description = "GKE Cluster Name"
  default     = "blockchain-cluster"
}

variable "network_name" {
  description = "VPC Network Name"
  default     = "blockchain-vpc"
}
