provider "google" {
  credentials = file("terraform-admin.json")
  project     = var.project
  region      = var.region
}

resource "google_compute_address" "external" {
  name = "external"
}

resource "google_compute_instance" "prometheus-server" {
  name         = "${var.name}-server"
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = var.image
    }
  }

  network_interface {
    network = var.network
    access_config {
      nat_ip = google_compute_address.external.address
    }
  }

  metadata_startup_script = templatefile("srv.sh", {
    ext_IP = google_compute_instance.prometheus-agent.network_interface[0].access_config[0].nat_ip, 
    int_IP = google_compute_instance.prometheus-agent.network_interface.0.network_ip,
    srv_ext_IP = google_compute_address.external.address})
}

resource "google_compute_instance" "prometheus-agent" {
  name         = "${var.name}-agent"
  machine_type = var.default_machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = var.image
    }
  }

  network_interface {
    network = var.network
    access_config {
    }
  }

  metadata_startup_script = file("agent.sh")
}


