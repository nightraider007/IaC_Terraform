terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "4.5.0"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      # This provider block configures the AzureRM provider with specific features.
      # The `features` block is used to enable or disable specific features of the AzureRM

      # provider. In this case, it prevents the deletion of a resource group if it contains any resources.
      # This is useful to avoid accidental deletion of resource groups that still have resources in them. 
      # The `resource_group` block is a nested block within the `features` block that specifically configures
      # the behavior of resource groups in the AzureRM provider.
      # The `prevent_deletion_if_contains_resources` option is set to true, which means that if a resource group
      # contains any resources, it cannot be deleted. This helps to ensure that resource groups are not accidentally deleted
      # when they still have resources in them, which could lead to data loss or service disruption.
      # The `azurerm` provider is used to interact with Azure resources, and the `features` block allows for fine-tuning
      # of the provider's behavior. The `resource_group` block is a specific configuration for    
      # resource groups within the AzureRM provider, allowing for more control over how resource groups are managed.
      prevent_deletion_if_contains_resources = true
    }

  } 

      

  client_id = "4cc6cbf3-3374-41df-b623-4ba071bb9b6c"
  client_secret = "q1e8Q~oE25-Eq2jj.nIYlFlxv7LYt6LXpQg54dwX"
  subscription_id = "420b6646-37ed-43f9-bc5e-f74001384aa8"  # From az account show
  tenant_id       = "2a144b72-f239-42d4-8c0e-6f0f17c48e33"  # From az account show
}

