data "azurerm_client_config" "current" {}
#--------------------------------------------------
# Terraform Core Settings and Provider Requirements
#--------------------------------------------------

terraform {
  required_version = ">= 1.8.0"


  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.4.0"
    }
  }
}


#-------------------------
# Azure Provider Configuration
#-------------------------
provider "azurerm" {

  # The features block is mandatory for the azurerm provider, even if empty  
  features {
    resource_group {
      prevent_deletion_if_contains_resources = true
    }

  } # Mandatory for azurerm, even if empty


  # Avoid hardcoding credentials here in production — instead use environment variables or a secrets vault
  client_id       = var.client_id
  client_secret   = var.client_secret
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
}




variable "client_id" {
  description = "Azure Client ID"
  type        = string
}

variable "client_secret" {
  description = "Azure Client Secret"
  type        = string
  sensitive   = true
}

variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
}

variable "tenant_id" {
  description = "Azure Tenant ID"
  type        = string
}


variable "project_config" {
  description = "object of core project configuration"
  type = object({
    project_name = string
    environment  = string
    location     = string
    pwd          = string
    tags         = map(string)

  })
}




#---------------------------
# Resource Group
#---------------------------
resource "azurerm_resource_group" "rg" {
  name     = "rg-${var.project_config.project_name}-${var.project_config.environment}"
  location = var.project_config.location

  tags = var.project_config.tags
}

#---------------------------
# Virtual Network
#---------------------------
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-${var.project_config.project_name}-${var.project_config.environment}"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

#---------------------------
# Subnet: Web
#---------------------------
resource "azurerm_subnet" "subnet_web" {
  name                 = "subnet-web"
  address_prefixes     = ["10.0.1.0/24"]
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
}

#---------------------------
# Subnet: DB
#---------------------------
resource "azurerm_subnet" "subnet_db" {
  name                 = "subnet-db"
  address_prefixes     = ["10.0.2.0/24"]
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
}

#---------------------------
# Network Security Group
#---------------------------


resource "azurerm_network_security_group" "nsg_web" {
  name                = "nsg-web"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
// maybe later refactor this to use dynamic blocks for rules tellme more copilot
  
  security_rule {
    name                       = "Allow-SSH"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-RDP"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }


  security_rule {
    name                       = "Allow-HTTPS"
    priority                   = 125
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }


  security_rule {
    name                       = "Allow-ICMP"
    priority                   = 130
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Icmp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }


}

#---------------------------
# NSG ↔ Subnet Association
#---------------------------
resource "azurerm_subnet_network_security_group_association" "nsg_subnet_web" {
  subnet_id                 = azurerm_subnet.subnet_web.id
  network_security_group_id = azurerm_network_security_group.nsg_web.id
}

resource "azurerm_network_interface_security_group_association" "nsg_nic_web" {
  network_interface_id      = azurerm_network_interface.nic_web.id
  network_security_group_id = azurerm_network_security_group.nsg_web.id
}




# NSG for DB subnet (example tighter rules)
resource "azurerm_network_security_group" "nsg_db" {
  name                = "nsg-db"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "Allow-SQL-Inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "1433"                                        # Example for MS SQL Server
    source_address_prefix      = azurerm_subnet.subnet_web.address_prefixes[0] # allow only web subnet
    destination_address_prefix = "*"
  }

  # Optionally deny everything else or allow specific traffic
}

# Associate NSG with DB subnet
resource "azurerm_subnet_network_security_group_association" "nsg_subnet_db" {
  subnet_id                 = azurerm_subnet.subnet_db.id
  network_security_group_id = azurerm_network_security_group.nsg_db.id
}







# Public IP Address for VM
resource "azurerm_public_ip" "vm_web_ip" {
  name                = "vm-web-analytics-ip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.project_config.tags
}

# Network Interface (with Public IP)
resource "azurerm_network_interface" "nic_web" {
  name                = "nic-web"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.subnet_web.id
    private_ip_address            = "10.0.1.10"
    private_ip_address_allocation = "Static"
    public_ip_address_id          = azurerm_public_ip.vm_web_ip.id
  }

  tags = var.project_config.tags
}

# VM Instance
resource "azurerm_windows_virtual_machine" "vm_web" {
  name                  = "vmWebAnalytics"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  size                  = "Standard_B2ats_v2"
  admin_username        = "Jaydyn"
  admin_password        = var.project_config.pwd  //admin_password = azurerm_key_vault_secret.admin_password.value # ❗Replace with a secure secret or use Key Vault
  network_interface_ids = [azurerm_network_interface.nic_web.id]

  zone                     = "1" # Based on "self-selected zone"
  provision_vm_agent       = true
  enable_automatic_updates = true
  patch_mode               = "AutomaticByPlatform" # Azure-orchestrated patching
  //hotpatching_enabled      = true

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    name                 = "osdisk-web"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition"
    version   = "latest"
  }

  boot_diagnostics {
    storage_account_uri = null # Required if enabled = true
  }

  tags = var.project_config.tags

  depends_on = [
    azurerm_network_interface.nic_web
  ]
}

/* resource "azurerm_virtual_machine_extension" "iis_and_diagnostics" {
  name                 = "iis-and-diagnostics"
  virtual_machine_id   = azurerm_windows_virtual_machine.vm_web.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  settings = jsonencode({
    fileUris = ["https://raw.githubusercontent.com/nightraider007/IaC_Terraform/main/0.Project/scripts/setup.ps1"]
  })

  protected_settings = jsonencode({
    commandToExecute = "powershell -ExecutionPolicy Unrestricted -File setup.ps1"
  })

  depends_on = [
    azurerm_windows_virtual_machine.vm_web
  ]
} */


resource "azurerm_virtual_machine_extension" "iis_and_diagnostics" {
  name                 = "custom-script"
  virtual_machine_id   = azurerm_windows_virtual_machine.vm_web.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  settings = jsonencode({
    fileUris = [
      "https://raw.githubusercontent.com/nightraider007/IaC_Terraform/main/0.Project/scripts/setup-vm.ps1"
      
    ]
    #,"https://raw.githubusercontent.com/nightraider007/IaC_Terraform/main/0.Project/scripts/setup-webfiles.ps1"
  })

  protected_settings = jsonencode({
    commandToExecute = "powershell -ExecutionPolicy Unrestricted -File setup-iis.ps1; powershell -ExecutionPolicy Unrestricted -File setup-webfiles.ps1"
  })

  # Ensure correct dependency ordering if needed
  depends_on = [     azurerm_windows_virtual_machine.vm_web  ]
}








# Output (Optional)
output "vnet_id" {
  value = azurerm_virtual_network.vnet.id
}

output "subnet_ids" {
  value = [azurerm_subnet.subnet_web.id, azurerm_subnet.subnet_db.id]
}

# outputs.tf

# Output the VM name
output "vm_name" {
  description = "The name of the Windows virtual machine"
  value       = azurerm_windows_virtual_machine.vm_web.name
}

# Output the VM private IP address (from NIC)
output "vm_private_ip" {
  description = "The private IP address assigned to the VM"
  value       = azurerm_network_interface.nic_web.ip_configuration[0].private_ip_address
}

# Output the VM public IP address
output "vm_public_ip" {
  description = "The public IP address assigned to the VM"
  value       = azurerm_public_ip.vm_web_ip.ip_address
}

# Output the DNS name label assigned to the public IP (if set)
output "vm_public_dns" {
  description = "The FQDN associated with the public IP (DNS label)"
  value       = azurerm_public_ip.vm_web_ip.fqdn
}


# Output the resource group name
output "resource_group_name" {
  description = "The resource group that contains the VM"
  value       = azurerm_resource_group.rg.name
}

# Output the network security group (NSG) ID for the web subnet
output "nsg_web_id" {
  description = "Network Security Group ID applied to the web subnet"
  value       = azurerm_network_security_group.nsg_web.id
}


# Create Key Vault with RBAC enabled
resource "azurerm_key_vault" "kv" {
  name                        = "${var.project_config.project_name}-${var.project_config.environment}-kv"
  location                    = var.project_config.location
  resource_group_name         = azurerm_resource_group.rg.name
  tenant_id                   = var.tenant_id
  sku_name                    = "standard"
  enable_rbac_authorization   = true    # <-- RBAC enabled instead of access policies

  tags = var.project_config.tags
}

#RBAC inheritance, control plane vs data plane, and role assignment constraints 
#ephemeral nature of Key Vault role assignments
# The user identity(SP) used to authenticate Terraform in this deployment is an 
# **application object** (a service principal) created through an Azure App Registration.
# Authentication is handled via the app's **client ID and client secret**, defined in the provider block.
#
# In order to allow this service principal to interact with the Key Vault (specifically, 
# to store secrets using RBAC-based access control), it has been assigned the necessary 
# **Key Vault Secrets Officer** and **Key Vault Secrets User** roles.
#
# However, role assignments on the Key Vault cannot be performed by this service principal alone,
# because the **Contributor** role (which it inherited at the Key Vault level) does **not** grant
# permission to assign RBAC roles (i.e., lacks `Microsoft.Authorization/roleAssignments/write`).
#
# To work around this:
# → The service principal was granted **User Access Administrator** (or **Owner**) **at the resource group level**.
# This ensures that any Key Vault created under that resource group will inherit the correct access context.
# RBAC roles for Key Vault: See full explanation in:
# ./0.Project/helper_files/read_comments.md
#
# As a result, Terraform was able to:
# - Create the Key Vault with `enable_rbac_authorization = true`
# - Assign the correct roles to the service principal
# - Create and store the admin password as a secret inside the Key Vault using RBAC


# Role 1: Key Vault Secrets User → Read/list secrets
/* resource "azurerm_role_assignment" "kv_secrets_user" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = data.azurerm_client_config.current.object_id
}

# Role 2: Key Vault Secrets Officer → Create/update/delete secrets
resource "azurerm_role_assignment" "kv_secrets_officer" {
  scope                = azurerm_key_vault.kv.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
} */



# Store secret in Key Vault
 resource "azurerm_key_vault_secret" "admin_password" {
  name         = "adminPassword"
  value        = var.project_config.pwd
  key_vault_id = azurerm_key_vault.kv.id
} 


