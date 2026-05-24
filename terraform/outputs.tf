# ==============================================================================
# Outputs Declaration File (outputs.tf)
# ==============================================================================
# This file defines the output values that are printed to the console upon
# successful execution of `terraform apply`.
#
# These outputs are designed to be easily read by operators or parsed by
# configuration management systems like Ansible.
# ==============================================================================

output "resource_group_name" {
  description = "The name of the Resource Group created on Azure."
  value       = azurerm_resource_group.rg.name
}

output "vm_public_ip_address" {
  description = "The allocated static Public IP Address of the Virtual Machine. Consumable by Ansible."
  value       = azurerm_public_ip.public_ip.ip_address
}

output "vm_name" {
  description = "The hostname of the provisioned Virtual Machine."
  value       = azurerm_linux_virtual_machine.vm.name
}

output "vm_ssh_connection_string" {
  description = "A helper SSH command string to quickly log into the newly provisioned Linux VM."
  value       = "ssh ${var.admin_username}@${azurerm_public_ip.public_ip.ip_address}"
}

output "frontend_access_url" {
  description = "The URL to access the React frontend container once deployed."
  value       = "http://${azurerm_public_ip.public_ip.ip_address}:${var.frontend_port}"
}
