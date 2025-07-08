#-------------------------------------------------- 
# Terraform Core Settings and Provider Requirements
#--------------------------------------------------
terraform {
  required_version = ">= 1.5.0"  # Ensures compatibility with Terraform features

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"  # Azure provider
      version = "~> 3.90.0"
    }
    aws = {
      source  = "hashicorp/aws"      # AWS provider
      version = "~> 5.40.0"
    }
    google = {
      source  = "hashicorp/google"   # Google Cloud provider
      version = "~> 5.20.0"
    }
  }
}

#-------------------------
# Azure Provider Config
#-------------------------
provider "azurerm" {
  features {}  # Required placeholder for azurerm provider

  # These are populated from variables or environment variables (e.g., ARM_CLIENT_ID)
  subscription_id = var.azure_subscription_id
  client_id       = var.azure_client_id
  client_secret   = var.azure_client_secret
  tenant_id       = var.azure_tenant_id
}

#-------------------------
# AWS Provider Config
#-------------------------
provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

#-------------------------
# Google Cloud Provider Config
#-------------------------
provider "google" {
  credentials = file(var.gcp_credentials_file)  # Path to the service account key JSON file
  project     = var.gcp_project
  region      = var.gcp_region
}

#-------------------------------
# Azure Resource Group Example
#   resource "<PROVIDER>_<RESOURCE_TYPE>" "<LOCAL_NAME>" {
        # configuration arguments
#   }
#-------------------------------
resource "azurerm_resource_group" "my_rg" {
  name     = "my-rg"
  location = "uksouth"
}

#Usage of the Local Resource Name (e.g., "my_rg")
#You reference it to retrieve attributes, like the actual name, ID, location, etc.

#Example:

resource "azurerm_virtual_network" "my_vnet" {
  name                = "vnet-01"
  location            = azurerm_resource_group.my_rg.location  # using the local name here
  resource_group_name = azurerm_resource_group.my_rg.name
  address_space       = ["10.0.0.0/16"]
}
#You can think of azurerm_resource_group.my_rg as an object with properties.
