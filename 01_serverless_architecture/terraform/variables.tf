variable "az_send" {
  type = bool
  default = false
}

variable "az_receive" {
  type = bool
  default = false
}

variable "deploy_az" {
  type = bool
  default = false
}

variable "gcp_send" {
  type = bool
  default = false
}

variable "gcp_receive" {
  type = bool
  default = false
}

variable "deploy_gcp" {
  type = bool
  default = false
}

variable "google_provider_project" {
  type = string
}

variable "google_provider_region" {
  type = string
}

variable "google_provider_zone" {
  type = string
}
