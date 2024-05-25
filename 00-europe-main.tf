# European Network and Subnetwork
resource "google_compute_network" "european_network" {
  name                    = "european-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "european_subnet" {
  name          = "european-subnet"
  ip_cidr_range = "10.150.0.0/20"
  region        = var.european_region
  network       = google_compute_network.european_network.id

}

# European Compute Engine
resource "google_compute_instance" "european_instance" {
  name         = "european-instance"
  machine_type = var.instance_type
  zone         = "${var.european_region}-b"

  boot_disk {
    initialize_params {
      image = var.instance_image
    }
  }

  network_interface {
    network    = google_compute_network.european_network.id
    subnetwork = google_compute_subnetwork.european_subnet.id
    access_config {
      // Ephemeral IP, no external IP
    }
  }
/*
  metadata_startup_script = file("${path.module}/startup-script.sh")
  */
metadata = {
    startup-script = "#Thanks to Remo\n#!/bin/bash\n# Update and install Apache2\napt update\napt install -y apache2\n\n# Start and enable Apache2\nsystemctl start apache2\nsystemctl enable apache2\n\n# GCP Metadata server base URL and header\nMETADATA_URL=\"http://metadata.google.internal/computeMetadata/v1\"\nMETADATA_FLAVOR_HEADER=\"Metadata-Flavor: Google\"\n\n# Use curl to fetch instance metadata\nlocal_ipv4=$(curl -H \"$${METADATA_FLAVOR_HEADER}\" -s \"$${METADATA_URL}/instance/network-interfaces/0/ip\")\nzone=$(curl -H \"$${METADATA_FLAVOR_HEADER}\" -s \"$${METADATA_URL}/instance/zone\")\nproject_id=$(curl -H \"$${METADATA_FLAVOR_HEADER}\" -s \"$${METADATA_URL}/project/project-id\")\nnetwork_tags=$(curl -H \"$${METADATA_FLAVOR_HEADER}\" -s \"$${METADATA_URL}/instance/tags\")\n\n# Create a simple HTML page and include instance details\ncat <<EOF > /var/www/html/index.html\n<html><body>\n<h2>Welcome to your custom website.</h2>\n<h3>Created with a direct input startup script!</h3>\n<p><b>Instance Name:</b> $(hostname -f)</p>\n<p><b>Instance Private IP Address: </b> $local_ipv4</p>\n<p><b>Zone: </b> $zone</p>\n<p><b>Project ID:</b> $project_id</p>\n<p><b>Network Tags:</b> $network_tags</p>\n</body></html>\nEOF"
  }
  tags = ["european-headquarters", "rdp-accessible"]

}

# Firewall rules to allow only allow traffic on port 80
resource "google_compute_firewall" "allow_http" {
  name    = "allow-http"
  network = google_compute_network.european_network.id
  allow {
    protocol = "tcp"
    ports    = ["80","3389"]
  }
    allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  allow {
    protocol = "icmp"
  }
  source_ranges = ["172.16.0.0/24", "172.16.1.0/24","10.150.0.0/20"]
  target_tags   = ["european-headquarters"]
}

resource "google_compute_vpn_gateway" "european_vpn_gateway" {
  name    = "european-vpn-gateway"
  region  = var.european_region
  network = google_compute_network.european_network.id
}

resource "google_compute_address" "european_vpn_gateway_ip" {
  name   = "european-vpn-gateway-ip"
  region = var.european_region
}

resource "google_compute_vpn_tunnel" "europe_to_asia_tunnel" {
  name                    = "europe-to-asia-tunnel"
  region                  = var.european_region
  target_vpn_gateway      = google_compute_vpn_gateway.european_vpn_gateway.id
  peer_ip                 = google_compute_address.asian_vpn_gateway_ip.address
  shared_secret           = var.vpn_shared_secret
  ike_version             = 2
  local_traffic_selector  = [google_compute_subnetwork.european_subnet.ip_cidr_range]
  #local_traffic_selector  = ["192.168.11.0/24"]
  remote_traffic_selector = [google_compute_subnetwork.asian_subnet.ip_cidr_range]
  /*
  depends_on = [
    google_compute_forwarding_rule.asian_esp,
    google_compute_forwarding_rule.asian_udp500
  ]
  */
}

resource "google_compute_forwarding_rule" "european_esp" {
  name        = "european-esp"
  region      = var.european_region
  ip_protocol = "ESP"
  ip_address  = google_compute_address.european_vpn_gateway_ip.address
  target      = google_compute_vpn_gateway.european_vpn_gateway.self_link
}

resource "google_compute_forwarding_rule" "european_udp500" {
  name        = "european-udp500"
  region      = var.european_region
  ip_protocol = "UDP"
  ip_address  = google_compute_address.european_vpn_gateway_ip.address
  port_range  = "500"
  target      = google_compute_vpn_gateway.european_vpn_gateway.self_link
}

resource "google_compute_forwarding_rule" "european_udp4500" {
  name        = "european-udp4500"
  region      = var.european_region
  ip_protocol = "UDP"
  ip_address  = google_compute_address.european_vpn_gateway_ip.address
  port_range  = "4500"
  target      = google_compute_vpn_gateway.european_vpn_gateway.self_link
}

resource "google_compute_route" "europe_to_asia_route" {
  name                  = "europe-to-asia-route"
  network               = google_compute_network.european_network.id
  dest_range            = google_compute_subnetwork.asian_subnet.ip_cidr_range
  next_hop_vpn_tunnel   = google_compute_vpn_tunnel.europe_to_asia_tunnel.id
  priority              = 1000
}

resource "google_compute_firewall" "allow_rdp" {
  name    = "allow-rdp"
  network = google_compute_network.european_network.id
  allow {
    protocol = "tcp"
    ports    = ["3389"]
  }

  source_ranges = ["192.168.0.0/24"]
  target_tags   = ["rdp-accessible"]
}

resource "google_project_service" "cloudresourcemanager" {
  service = "cloudresourcemanager.googleapis.com"
}