# 1. Provider Configuration
provider "google" {
  project = "project-f561a2e0-7d0d-4ebe-948"
  region  = var.region
}

# 2. Variable Definitions (Crucial for the resources below)
variable "region" {
  type    = string
  default = "us-central1"
}

variable "env" {
  type    = string
  default = "dev"
}

# 3. Networking Resources
resource "google_compute_network" "main" {
  name                    = "vpc-${var.env}"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "private" {
  name                     = "subnet-${var.env}"
  ip_cidr_range            = "10.0.1.0/24"
  region                   = var.region
  network                  = google_compute_network.main.id
  private_ip_google_access = true
}

resource "google_compute_router" "router" {
  name    = "router-${var.env}"
  region  = var.region
  network = google_compute_network.main.id
}

resource "google_compute_router_nat" "nat" {
  name                               = "nat-${var.env}"
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

# 4. Outputs (To use in your GKE module)
output "vpc_id" {
  value = google_compute_network.main.id
}

output "subnet_id" {
  value = google_compute_subnetwork.private.id
}