

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
