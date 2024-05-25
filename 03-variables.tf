terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "5.28.0"
    }
  }
}

provider "google" {
  credentials = var.credentials
  project     = var.project_id
  region      = var.european_region
}

variable "project_id" {
  default     = "terraform-gcp-justjules"
  description = "value of the project id"
}

variable "credentials" {
  default     = "D:\\Career\\BlackManosphere\\01-GCP\\20240511\\terraform-gcp-justjules.json"
  description = "value of the credentials"
  sensitive   = true
}

variable "vpn_shared_secret" {
  description = "Shared secret for the VPN connection"
  default     = "terraform-gcp-secret"
  sensitive   = true
}

variable "european_region" {
  default     = "europe-west1"
  description = "value of the european region"
}

variable "american1_region" {
  default     = "us-west1"
  description = "value of the american region1"
}

variable "american2_region" {
  default     = "us-east1"
  description = "value of the american region2"
}

variable "asian_region" {
  default     = "asia-east1"
  description = "value of the asian region"
}

variable "instance_type" {
  default     = "e2-medium"
  description = "value of the instance type"
}

variable "instance_image" {
  default     = "debian-cloud/debian-11"
  description = "value of the instance image"
}

variable "windows_instance_type" {
  default     = "n1-standard-2"
  description = "value of the windows instance type"
}

variable "windows_instance_image" {
  default     = "windows-cloud/windows-2019"
  description = "value of the windows instance image"
}

variable "asian_vpn_peer_ip" {
  description = "Peer IP address of the Asian VPN Gateway"
  type        = string
  default     = ""
}

variable "europe_vpn_peer_ip" {
  description = "Peer IP address of the Europe VPN Gateway"
  type        = string
  default     = "10.150.11.0"
}

variable "vpn_gateway_ip" {
  description = "IP address of the VPN Gateway"
  type        = string
  default     = "192.168.11.0"
  #default     = "192.168.0.0"
}

variable "elastic_ip_europe" {
  description = "description of the european elastic ip address"
  default     = "elastic-ip-europe"
}

variable "elastic_ip_american1" {
  description = "description of the american1 elastic ip address"
  default     = "elastic-ip-american1"
}

variable "elastic_ip_american2" {
  description = "description of the american 2 elastic ip address"
  default     = "elastic-ip-american2"
}

variable "elastic_ip_asian" {
  description = "description of the asian elastic ip address"
  default     = "elastic-ip-asian"
}