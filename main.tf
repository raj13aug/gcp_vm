data "google_compute_image" "demo" {
  family  = "ubuntu-2204-lts"
  project = "ubuntu-os-cloud"
}

locals {
  region            = "us-east1"
  availability_zone = "us-east1-d"
}

resource "google_project" "project" {
  name = var.name

  org_id          = var.organization_id
  billing_account = var.billing_account_id
  project_id      = var.id != "" ? var.id : replace(lower(var.name), " ", "-")
}


resource "google_service_account" "demo" {
  project = google_project.project.project_id

  account_id   = "demo-instance"
  display_name = "Custom Service Account for a Demo VM Instance"
}


resource "google_compute_instance" "demo" {
  project = google_project.project.project_id

  name         = "demo"
  machine_type = "n1-standard-1"
  zone         = "${local.region}-d"

  tags = ["demo"]

  boot_disk {
    auto_delete = true

    initialize_params {
      image = data.google_compute_image.demo.self_link

      labels = {
        managed_by = "terraform"
      }
    }
  }

  network_interface {

    access_config {
      // Ephemeral public IP
    }
  }

  metadata = {
    google-logging-enabled    = "true"
    google-monitoring-enabled = "true"
  }

  # We can install any tools we need for the demo in the startup script
  metadata_startup_script = <<EOT
  set -xe \
    && sudo apt update -y \
    && sudo apt install postgresql-client jq iperf3 -y 
EOT

  allow_stopping_for_update = true

  resource_policies = [google_compute_resource_policy.uptime_schedule.id]
}

resource "google_compute_firewall" "demo-ssh-ipv4" {
  project = google_project.project.project_id

  name    = "staging-demo-ssh-ipv4"
  network = google-cloud-vpc.id

  allow {
    protocol = "tcp"
    ports    = [22]
  }

  allow {
    protocol = "udp"
    ports    = [22]
  }

  allow {
    protocol = "sctp"
    ports    = [22]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = google_compute_instance.demo.tags
}