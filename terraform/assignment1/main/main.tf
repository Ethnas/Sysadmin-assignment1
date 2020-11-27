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

  project = var.project_name
  region  = var.region_name
  zone    = var.zone_name
}

resource "google_compute_address" "webserver" {
  count = var.ip_count
  name = "webserver-address-${count.index}"
  region = var.region_name
}

# resource "google_compute_network" "vpc_network" {
#   name = "terraform-network"
#   auto_create_subnetworks = "true"
# }

resource "google_compute_firewall" "default" {
  name    = "apache-firewall"
  network = "default"
 
  allow {
    protocol = "tcp"
    ports    = ["80","443"]
  }
 
  allow {
    protocol = "icmp"
  }
}

resource "google_compute_instance" "webserver" {
  count = var.instance_number
  name         = "terraform-webserver-${count.index}"
  machine_type = "e2-small"

  metadata = {
	ssh-keys = "erlendniko@gmail.com:${file("ssh-key.pub")}"
  }

  boot_disk {
    initialize_params {
      image = var.image_name
    }
  }
    network_interface {
      # A default network is created for all GCP projects
      network = "default"
      access_config {
        nat_ip = google_compute_address.webserver[count.index].address
    }
  }

  # Save the public IP for testing
    provisioner "local-exec" {
	    command = "echo ${google_compute_instance.webserver[0].name} ${google_compute_instance.webserver[0].network_interface[0].access_config[0].nat_ip} >> ip_address.txt"
  }

  provisioner "local-exec" {
    command = "echo ${google_compute_address.webserver[count.index].address}"
  }

  # Copies a script to the vm
    provisioner "file" {
	    source = "../scripts/webserver.sh"
	    destination = "/etc/webserver.sh"
  }

  #Run script for installing Apache web server
    provisioner "remote-exec" {
	    script = "../scripts/webserver.sh"
	    connection {
	      type = "ssh"
        host = google_compute_address.webserver[count.index].address
	      user = var.username
	      timeout = "1m"
	      private_key = file("ssh-key")
        #host_key = file("ssh-key.pub")
	  }
  }
}

  



