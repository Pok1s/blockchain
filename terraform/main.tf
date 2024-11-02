provider "google" {
  project = var.project_id
  region  = var.region
}


resource "google_compute_network" "vpc" {
  name                    = var.network_name
  auto_create_subnetworks = false
}


resource "google_compute_subnetwork" "subnet" {
  name          = "${var.network_name}-subnet"
  region        = var.region
  network       = google_compute_network.vpc.name
  ip_cidr_range = "10.0.0.0/16"
}


resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = "${var.region}-b"


  remove_default_node_pool = true
  initial_node_count       = 1

  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.subnet.name

  ip_allocation_policy {
    cluster_ipv4_cidr_block  = "10.100.0.0/16"
    services_ipv4_cidr_block = "10.101.0.0/16"
  }
}


resource "google_container_node_pool" "primary_nodes" {
  name     = "${var.cluster_name}-node-pool"
  location = "${var.region}-b"
  cluster  = google_container_cluster.primary.name

  node_count = 1

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/devstorage.read_only"
    ]

    machine_type = "e2-standard-8"
    disk_size_gb = 250

    labels = {
      env = "blockchain"
    }
  }
}


resource "google_compute_router" "router" {
  name    = "${var.network_name}-router"
  region  = var.region
  network = google_compute_network.vpc.id
}

resource "google_compute_router_nat" "nat" {
  name                               = "${var.network_name}-nat"
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}
