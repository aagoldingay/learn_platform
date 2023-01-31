terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.41.0"
    }
    google = {
      source  = "hashicorp/google"
      version = "~>4.51.0"
    }
  }

  # location of remote state (this is independent of accompanying resources. e.g. backend could be AWS or local)
  backend "azurerm" {
    # resource_group_name  = "state_resource_group"
    # storage_account_name = "state_storage_account"
    # container_name       = "state_container"
    # key                  = "state_filename"
  }
  # initialising secretly, without configuring directly within providers.tf:
  # terraform init -backend-config="resource_group_name=<state_resource_group>" \
  #   -backend-config="storage_account_name=<state_storage_account>" \
  #   -backend-config="container_name=<state_container>" \
  #   -backend-config="key=<state_filename>" \
}

provider "azurerm" {
  features {}
}

provider "google" {
  project = var.google_provider_project
  region  = var.google_provider_region
  zone    = var.google_provider_zone
}
