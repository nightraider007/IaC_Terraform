
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

  security_rule {
    name                       = "Allow-HTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

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
  admin_password        = var.project_config.pwd # ❗Replace with a secure secret or use Key Vault
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

resource "azurerm_virtual_machine_extension" "iis_and_diagnostics" {
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
}



