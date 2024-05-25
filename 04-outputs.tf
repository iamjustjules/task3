output "europe_vpn_gateway_ip" {
  value       = var.europe_vpn_peer_ip
  description = "The Peer IP address of the European VPN gateway."
}

output "network_id" {
  value       = google_compute_network.asian_network.id
  description = "value of the network id"
}

output "vpn_gateway_ip" {
  value       = google_compute_address.asian_vpn_gateway_ip.address
  description = "IP Address of the VPN Gateway"
}

output "asian_vpn_gateway_ip" {
  value       = google_compute_address.asian_vpn_gateway_ip.address
  description = "IP Address of the Asian VPN Gateway"
}

output "vpn_shared_secret" {
  value       = var.vpn_shared_secret
  description = "Shared secret used for the VPN"
  sensitive   = true
}

output "vpn_peer_ip" {
  value       = var.europe_vpn_peer_ip
  description = "Peer IP Address for VPN Connection"
}

output "european_instance_ip" {
  value       = google_compute_instance.european_instance.network_interface.0.access_config.0.nat_ip
  description = "NAT IP address of the European instance for RDP access."
}

output "american1_instance_ip" {
  value       = google_compute_instance.american1-instance.network_interface.0.access_config.0.nat_ip
  description = "NAT IP address of the American instance for SSH access."
}

output "american1_instance_ssh" {
  value       = "ssh ${google_compute_instance.american1-instance.network_interface.0.access_config.0.nat_ip}"
  description = "Command to SSH into the American1 instance."
}

output "american2_instance_ip" {
  value       = google_compute_instance.american2-instance.network_interface.0.access_config.0.nat_ip
  description = "NAT IP address of the American instance for SSH access."
}

output "asian_instance_ip" {
  value       = google_compute_instance.asian_instance.instance_id
  description = "NAT IP address of the Asian instance for RDP access."
}

output "european_instance_environment" {
  value       = google_compute_instance.european_instance.metadata_startup_script
  description = "Environment metadata for the European compute instance."
}

output "european_instance_webpage_url" {
  value       = "http://${google_compute_instance.european_instance.network_interface[0].access_config[0].nat_ip}/index.html"
  description = "URL to access the hosted index.html on the European compute instance."
}

