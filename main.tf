terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~>3.0"
    }
  }
}

provider "google" {
  region  = "europe-west1"
  project = "lbg-cloud-incubation"
}

resource "google_compute_network" "vpc_network" {
  name = "my-terraform-network"
}

resource "google_compute_subnetwork" "public" {
  name          = "public-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = "europe-west1"
  network       = google_compute_network.vpc_network.id
}

resource "google_compute_firewall" "allow_http_one" {
    name = "allow-http-rule-80"
    network = "default"
    
    allow {
      ports = ["80"]
      protocol = "tcp"
    }

    target_tags = ["allow-http-one"]

    priority = 1000
  
}

resource "google_compute_firewall" "allow_http_two" {
    name = "allow-http-rule-8080"
    network = "default"
    
    allow {
      ports = ["8080"]
      protocol = "tcp"
    }

    target_tags = ["allow-http-two"]

    priority = 1000
  
}

resource "google_compute_address" "staticip-app" {
  name = "ubuntu-app"
}

resource "google_compute_address" "staticip-jenkins" {
  name = "ubuntu-jenkins"
}

resource "google_compute_instance" "ubuntu-app" {
  name = "ubuntu-app"
  zone = "europe-west1-b"
  tags = ["allow-http-one"]

  machine_type = "e2-micro"

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }

  network_interface {
    network = "default"

    access_config {
      nat_ip = google_compute_address.staticip-app.address
    }
  }
}

resource "google_compute_instance" "ubuntu-jenkins" {
  name = "ubuntu-jenkins"
  zone = "europe-west1-b"
  tags = ["allow-http-two"]

  machine_type = "e2-micro"

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2004-lts"
    }
  }

  network_interface {
    network = "default"

    access_config {
      nat_ip = google_compute_address.staticip-jenkins.address
    }
  }

  metadata_startup_script = file("startup_script.sh")
}