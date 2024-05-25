resource "google_compute_network" "asian_network" {
  name                    = "asian-network"
  description             = "Network for the Asian region"
  auto_create_subnetworks = false
  routing_mode            = "GLOBAL"
  mtu                     = 1460
}

resource "google_compute_subnetwork" "asian_subnet" {
  name          = "asian-subnet"
  ip_cidr_range = "192.168.0.0/24"
  region        = var.asian_region
  network       = google_compute_network.asian_network.id
}

resource "google_compute_instance" "asian_instance" {
  depends_on   = [google_compute_subnetwork.asian_subnet]
  name         = "asian-instance"
  machine_type = var.instance_type
  zone         = "${var.asian_region}-b"
  boot_disk {
    initialize_params {
      image = var.instance_image
    }

  }

  network_interface {
    network    = google_compute_network.asian_network.id
    subnetwork = google_compute_subnetwork.asian_subnet.id
    access_config {
      // Ephemeral IP, no external IP
    }
  }

  tags = ["asian-instance", "vpn", "iam-ssh-allowed"]
}

resource "google_compute_firewall" "asian_rdp" {
  name    = "asian-rdp"
  network = google_compute_network.asian_network.id
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports    = ["3389"]
  }
  #source_ranges = ["192.168.0.0/24"]
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_vpn_gateway" "asian_vpn_gateway" {
  name    = "asia-vpn-gateway"
  region  = var.asian_region
  network = google_compute_network.asian_network.id
}

resource "google_compute_address" "asian_vpn_gateway_ip" {
  name   = "asia-vpn-gateway-ip"
  region = var.asian_region
}

resource "google_compute_forwarding_rule" "asian_esp" {
  name        = "asia-esp"
  region      = var.asian_region
  ip_protocol = "ESP"
  ip_address  = google_compute_address.asian_vpn_gateway_ip.address
  target      = google_compute_vpn_gateway.asian_vpn_gateway.self_link
  depends_on  = [google_compute_vpn_gateway.european_vpn_gateway]
}

resource "google_compute_forwarding_rule" "asian_udp500" {
  name        = "asia-udp500"
  region      = var.asian_region
  ip_protocol = "UDP"
  ip_address  = google_compute_address.asian_vpn_gateway_ip.address
  port_range  = "500"
  target      = google_compute_vpn_gateway.asian_vpn_gateway.self_link
  depends_on  = [google_compute_vpn_gateway.european_vpn_gateway]
}

resource "google_compute_forwarding_rule" "asian_udp4500" {
  name        = "asia-udp4500"
  region      = var.asian_region
  ip_protocol = "UDP"
  ip_address  = google_compute_address.asian_vpn_gateway_ip.address
  port_range  = "4500"
  target      = google_compute_vpn_gateway.asian_vpn_gateway.self_link
  depends_on  = [google_compute_vpn_gateway.european_vpn_gateway]
}

resource "google_compute_vpn_tunnel" "asian_to_europe_tunnel" {
  name                    = "asia-to-europe-tunnel"
  region                  = var.asian_region
  target_vpn_gateway      = google_compute_vpn_gateway.asian_vpn_gateway.id
  peer_ip                 = google_compute_address.european_vpn_gateway_ip.address
  shared_secret           = var.vpn_shared_secret
  ike_version             = 2
  local_traffic_selector  = [google_compute_subnetwork.asian_subnet.ip_cidr_range]
  remote_traffic_selector = [google_compute_subnetwork.european_subnet.ip_cidr_range]
  depends_on = [
    google_compute_forwarding_rule.asian_esp,
    google_compute_forwarding_rule.asian_udp500
  ]
}