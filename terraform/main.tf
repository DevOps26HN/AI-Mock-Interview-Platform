# ==============================================================================
# Infrastructure Main Declaration File (main.tf)
# ==============================================================================
# This file declares resources sequentially in order of resource dependencies.
# The compute layer (VM) is isolated within a custom virtual network and is
# guarded by a Network Security Group (NSG) with strict ingress policies.
#
# Crucial Separation of Concerns:
#   Terraform manages ONLY the infrastructure provisioning (Resource Group, VNet,
#   IP, NSG, VM). It outputs the public IP so that Ansible can perform
#   configuration management (installing Docker, configuring the compose stack).
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. Resource Group
# ------------------------------------------------------------------------------
# A logical container that groups related resources together for Azure deployment.
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    Environment = "production-grade"
    Project     = "AI Mock Interview Platform"
    ManagedBy   = "Terraform"
  }
}

# ------------------------------------------------------------------------------
# 2. Virtual Network & Subnet
# ------------------------------------------------------------------------------
# Establishes an isolated private network partition on Azure for secure communication.
resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = var.vnet_address_space

  tags = {
    Environment = "production-grade"
    Project     = "AI Mock Interview Platform"
  }
}

resource "azurerm_subnet" "subnet" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.subnet_address_prefix
}

# ------------------------------------------------------------------------------
# 3. Public IP Address
# ------------------------------------------------------------------------------
# Allocates a static public IP address. Using Static allocation guarantees the 
# IP does not change on VM reboot, which is critical for Ansible inventories.
resource "azurerm_public_ip" "public_ip" {
  name                = var.public_ip_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard" # Standard SKU is recommended for production and supports Static allocation

  tags = {
    Environment = "production-grade"
    Project     = "AI Mock Interview Platform"
  }
}

# ------------------------------------------------------------------------------
# 4. Network Security Group (NSG)
# ------------------------------------------------------------------------------
# Acting as a virtual firewall, this blocks all ingress traffic except for rules
# explicitly allowed. Outbound traffic remains permitted.
resource "azurerm_network_security_group" "nsg" {
  name                = var.nsg_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  tags = {
    Environment = "production-grade"
    Project     = "AI Mock Interview Platform"
  }
}

# ------------------------------------------------------------------------------
# 5. Network Security Rules (Strict Ingress Firewall Settings)
# ------------------------------------------------------------------------------

# Rule 1: SSH (Port 22) - Permitted only from the authorized administrator prefix
resource "azurerm_network_security_rule" "ssh" {
  name                        = "Allow-SSH-Inbound"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = var.ssh_source_address_prefix
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

# Rule 2: React Frontend (Port 3000) - Exposed to serve the client container
resource "azurerm_network_security_rule" "frontend" {
  name                        = "Allow-Frontend-Port-Inbound"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = tostring(var.frontend_port)
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

# Rule 2b: Spring Boot Backend (Port 8080) - Exposed to serve the server container
resource "azurerm_network_security_rule" "backend" {
  name                        = "Allow-Backend-Port-Inbound"
  priority                    = 115
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = tostring(var.backend_port)
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

# Rule 3: Standard HTTP (Port 80) - Optional, enabled by variable toggle
resource "azurerm_network_security_rule" "http" {
  count                       = var.enable_http ? 1 : 0
  name                        = "Allow-HTTP-Inbound"
  priority                    = 120
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

# Rule 4: Standard HTTPS (Port 443) - Optional, enabled by variable toggle
resource "azurerm_network_security_rule" "https" {
  count                       = var.enable_https ? 1 : 0
  name                        = "Allow-HTTPS-Inbound"
  priority                    = 130
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

# ------------------------------------------------------------------------------
# 6. Network Interface (NIC) & NSG Association
# ------------------------------------------------------------------------------
# Links the subnet IP allocation, static Public IP, and the VM itself.
resource "azurerm_network_interface" "nic" {
  name                = var.nic_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal-ip-config"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }

  tags = {
    Environment = "production-grade"
    Project     = "AI Mock Interview Platform"
  }
}

# Connect the NSG directly to the Network Interface (NIC) for immediate enforcement
resource "azurerm_network_interface_security_group_association" "nic_nsg_assoc" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# ------------------------------------------------------------------------------
# 7. Linux Virtual Machine
# ------------------------------------------------------------------------------
# Deploys a stable Ubuntu Server 22.04 LTS instance with SSH key authentication.
resource "azurerm_linux_virtual_machine" "vm" {
  name                  = var.vm_name
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  size                  = var.vm_size
  admin_username        = var.admin_username
  network_interface_ids = [azurerm_network_interface.nic.id]

  # Enforce SSH public-key authentication for high security
  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.ssh_public_key_path)
  }

  # OS Disk configuration using locally redundant storage (LRS) for low cost
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = var.os_disk_size_gb
  }

  # Deploying Ubuntu Server 22.04 LTS (Jammy Jellyfish) Gen 2
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  # Ensure the VM is not created before the NIC and NSG are fully bound
  depends_on = [
    azurerm_network_interface_security_group_association.nic_nsg_assoc
  ]

  tags = {
    Environment = "production-grade"
    Project     = "AI Mock Interview Platform"
  }
}
