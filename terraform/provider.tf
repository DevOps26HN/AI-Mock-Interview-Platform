# ==============================================================================
# Provider Configuration File (provider.tf)
# ==============================================================================
# This file defines the required Terraform version and provider configurations.
# It establishes version constraints to ensure reproducibility and stability
# across multiple runs and operator environments.
#
# Authentication Strategy:
#   The operator is assumed to have authenticated with the Azure Cloud via
#   the Azure CLI locally by running `az login` prior to executing Terraform.
# ==============================================================================

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.90.0" # Locking to a stable major/minor releases of 3.x
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  # Features block is required for the azurerm provider. It can be used to customize resource deletion behavior.
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false # Safely recreate resources when needed
    }
    virtual_machine {
      delete_os_disk_on_deletion     = true
      graceful_shutdown              = false
      skip_shutdown_and_force_delete = false
    }
  }
}
