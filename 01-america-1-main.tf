# American Networks and Subnetworks
resource "google_compute_network" "american1_network" {
  name                    = "american1-network"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "american1_subnet" {
  name          = "american1-subnet"
  ip_cidr_range = "172.16.0.0/24"
  region        = var.american1_region
  network       = google_compute_network.american1_network.id
}

resource "google_compute_instance" "american1-instance" {
  depends_on   = [google_compute_subnetwork.american1_subnet]
  name         = "american1-instance"
  machine_type = var.instance_type
  zone         = "${var.american1_region}-b"

  boot_disk {
    initialize_params {
      image = var.instance_image
    }
  }

  network_interface {
    network    = google_compute_network.american1_network.id
    subnetwork = google_compute_subnetwork.american1_subnet.id
    access_config {
      // Ephemeral IP, no external IP
    }
  }
 metadata = {
    startup-script = "#Thanks to Remo\n#!/bin/bash\n# Update and install Apache2\napt update\napt install -y apache2\n\n# Start and enable Apache2\nsystemctl start apache2\nsystemctl enable apache2\n\n# GCP Metadata server base URL and header\nMETADATA_URL=\"http://metadata.google.internal/computeMetadata/v1\"\nMETADATA_FLAVOR_HEADER=\"Metadata-Flavor: Google\"\n\n# Use curl to fetch instance metadata\nlocal_ipv4=$(curl -H \"$${METADATA_FLAVOR_HEADER}\" -s \"$${METADATA_URL}/instance/network-interfaces/0/ip\")\nzone=$(curl -H \"$${METADATA_FLAVOR_HEADER}\" -s \"$${METADATA_URL}/instance/zone\")\nproject_id=$(curl -H \"$${METADATA_FLAVOR_HEADER}\" -s \"$${METADATA_URL}/project/project-id\")\nnetwork_tags=$(curl -H \"$${METADATA_FLAVOR_HEADER}\" -s \"$${METADATA_URL}/instance/tags\")\n\n# Create a simple HTML page and include instance details\ncat <<EOF > /var/www/html/index.html\n<html><body>\n<h2>Welcome to your custom website.</h2>\n<h3>Created with a direct input startup script!</h3>\n<p><b>Instance Name:</b> $(hostname -f)</p>\n<p><b>Instance Private IP Address: </b> $local_ipv4</p>\n<p><b>Zone: </b> $zone</p>\n<p><b>Project ID:</b> $project_id</p>\n<p><b>Network Tags:</b> $network_tags</p>\n</body></html>\nEOF"
  }

  tags = ["american1-instance", "vpn", "iam-ssh-allowed","open-to-all"]
}

# Peering between American and European Networks
resource "google_compute_network_peering" "american1_to_european_peering1" {
  name         = "american1-to-eu-peering1"
  network      = google_compute_network.american1_network.id
  peer_network = google_compute_network.european_network.id
}

resource "google_compute_network_peering" "european_to_american1_peering1" {
  name         = "european-to-american1-peering1"
  network      = google_compute_network.european_network.id
  peer_network = google_compute_network.american1_network.id
}

resource "google_compute_firewall" "internal_http1" {
  name    = "internal-http1"
  network = google_compute_network.american1_network.id
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports    = ["80", "22"]
  }
  source_tags   = ["vpn"]
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["american1-instance", "iap-ssh-allowed","open-to-all"]
}

