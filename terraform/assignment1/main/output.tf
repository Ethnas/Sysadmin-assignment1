output "public_ip" {
 value = google_compute_instance.webserver.*.network_interface.0.access_config.0.nat_ip
}

output "public_ip2" {
    value = google_compute_address.webserver.*.address
}

output "public_ip3" {
    value = self.network_interface.0.access_config.0.nat_ip
}