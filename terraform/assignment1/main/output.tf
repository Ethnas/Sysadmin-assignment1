# output "public_ip" {
#     value = self.network_interface.0.access_config.0.nat_ip
# }

output "public_ip2" {
    value = google_compute_address.webserver.*.address
}

output "public_ip3" {
    value = google_compute_instance.webserver.*.network_interface.0.access_config.0.nat_ip
}

output "public_ip4" {
    value = google_compute_instance.webserver[0].network_interface[0].access_config[0].nat_ip
}

output "public_ip5" {
    value = google_compute_address.webserver[0].address
}

output "public_ip6" {
    value = google_compute_address.webserver.0.address
}