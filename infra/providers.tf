terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.50"
    }

    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.115"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }

    oci = {
      source  = "oracle/oci"
      version = ">= 7.0.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

provider "azurerm" {
  features {}
  subscription_id = var.azure_subscription_id
  tenant_id       = var.azure_tenant_id
}

# OCI will read credentials from ~/.oci/config (DEFAULT profile),
# so you don’t hardcode keys in Terraform.
provider "oci" {
  region              = var.oci_region
  config_file_profile = "DEFAULT"
}
