variable "az_send" {
  type    = bool
  default = false
}

variable "az_receive" {
  type    = bool
  default = false
}

variable "deploy_az" {
  type    = bool
  default = false
}

variable "gcp_send" {
  type    = bool
  default = false
}

variable "gcp_receive" {
  type    = bool
  default = false
}

variable "deploy_gcp" {
  type    = bool
  default = false
}

variable "project_name" {
  type = bool
}

variable "google_provider_project" {
  type    = string
  default = ""
}

variable "google_provider_region" {
  type    = string
  default = ""
}

# variable "google_provider_zone" {
#   type    = string
#   default = ""
# }
