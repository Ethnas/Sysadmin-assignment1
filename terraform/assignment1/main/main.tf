terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
    }
  }
}

provider "google" {
  version = "3.5.0"

  credentials = file("terraform-service-key.json")

  project = "test-ansible-291511"
  region  = "europe-north1"
  zone    = "europe-north1-a"
}

resource "google_compute_network" "vpc_network" {
  name = "terraform-network"
  auto_create_subnetworks = "true"
}

resource "google_compute_instance" "web_server" {
  name         = "terraform-instance1"
  machine_type = "e2-small"

  metadata = {
	ssh-keys = "erlendniko@gmail.com:${file("tf-packer.pub")}"
  }

  boot_disk {
    initialize_params {
      image = "ubuntu-2004-focal-v20201028"
    }
  }
  network_interface {
    # A default network is created for all GCP projects
    network = "default"
    access_config {
    }
  }

  # Save the public IP for testing
    provisioner "local-exec" {
	command = "echo ${google_compute_instance.web_server.name} ${google_compute_instance.web_server.network_interface[0].access_config[0].nat_ip} >> ip_address.txt"
  }

  # Copies a script to the vm
   provisioner "file" {
	source = "../scripts/webserver.sh"
	destination = "/etc/webserver.sh"
  }

  # Run script for installing Apache web server
   provisioner "remote-exec" {
	script = "../scripts/webserver.sh"
	connection {
	 type = "ssh"
   host = self.network_interface.0.access_config.0.nat_ip
	 user = "erlendniko@gmail.com"
	 timeout = "1m"
	 private_key = file("service-privatekey")
	}
  }
}
  output "ip" {
	value = google_compute_instance.web_server.network_interface.0.access_config.0.nat_ip
  }



