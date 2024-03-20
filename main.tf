data "google_compute_image" "demo" {
  family  = "ubuntu-2204-lts"
  project = "ubuntu-os-cloud"
}

locals {
  region            = "us-central1"
  availability_zone = "us-central1-a"
}



resource "google_compute_instance" "demo" {
  project = var.project_id

  name         = var.name
  machine_type = "e2-micro"
  zone         = "${local.region}-a"

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
    network = "default"
    access_config {
      // Ephemeral public IP
    }
  }

  #https://8gwifi.org/sshfunctions.jsp
  metadata = {
    sshKeys = file("./assets/ssh_keys")
  }

  # We can install any tools we need for the demo in the startup script
  metadata_startup_script = <<EOT
  set -xe \
    && sudo apt update -y \
    && sudo apt install postgresql-client jq iperf3 -y 
EOT

  allow_stopping_for_update = true

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
