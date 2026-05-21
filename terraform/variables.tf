# ==============================================================================
# Variables Declaration File (variables.tf)
# ==============================================================================
# All configurable settings are declared here with standard types, descriptions,
# and sensible default values. Hardcoded environment values are prohibited.
# ==============================================================================

# ------------------------------------------------------------------------------
# General / Resource Group Configuration
# ------------------------------------------------------------------------------
variable "resource_group_name" {
  type        = string
  description = "The name of the Azure Resource Group where all resources will be created."
  default     = "rg-ai-mock-interview"
}

variable "location" {
  type        = string
  description = "The Azure region to deploy our virtual network and compute resources."
  default     = "swedencentral" # Default region
}

# ------------------------------------------------------------------------------
# Networking Configuration
# ------------------------------------------------------------------------------
variable "vnet_name" {
  type        = string
  description = "The name of the Azure Virtual Network (VNet)."
  default     = "vnet-ai-mock-interview"
}

variable "vnet_address_space" {
  type        = list(string)
  description = "The address space allocated to the Virtual Network."
  default     = ["10.0.0.0/16"]
}

variable "subnet_name" {
  type        = string
  description = "The name of the subnet within the Virtual Network."
  default     = "subnet-ai-mock-interview"
}

variable "subnet_address_prefix" {
  type        = list(string)
  description = "The address prefix within the VNet subnet."
  default     = ["10.0.1.0/24"]
}

variable "public_ip_name" {
  type        = string
  description = "The name of the public IP resource assigned to the VM's NIC."
  default     = "pip-ai-mock-interview"
}

variable "nsg_name" {
  type        = string
  description = "The name of the Network Security Group (NSG) securing our VM."
  default     = "nsg-ai-mock-interview"
}

variable "nic_name" {
  type        = string
  description = "The name of the Network Interface (NIC) for the Virtual Machine."
  default     = "nic-ai-mock-interview"
}

# ------------------------------------------------------------------------------
# Security Rules Configuration (Strict Firewall Ingress)
# ------------------------------------------------------------------------------
variable "ssh_source_address_prefix" {
  type        = string
  description = "The CIDR block or IP address allowed to SSH into the VM. Highly recommended to restrict this in production."
  default     = "*" # Defaulting to * for convenience, override with specific operator IP in production
}

variable "frontend_port" {
  type        = number
  description = "The public port mapping on the host for the React frontend container."
  default     = 3000
}

variable "enable_http" {
  type        = bool
  description = "Toggle to open port 80 for HTTP traffic (useful if running Nginx/reverse proxy on host)."
  default     = true
}

variable "enable_https" {
  type        = bool
  description = "Toggle to open port 443 for HTTPS traffic."
  default     = true
}

# ------------------------------------------------------------------------------
# Compute (Virtual Machine) Configuration
# ------------------------------------------------------------------------------
variable "vm_name" {
  type        = string
  description = "The hostname and resource name of the Linux Virtual Machine."
  default     = "vm-ai-mock-interview"
}

variable "vm_size" {
  type        = string
  description = "The size/SKU of the Azure Virtual Machine."
  default     = "Standard_D2s_v3" # Economical burstable instance, ideal for testing
}

variable "admin_username" {
  type        = string
  description = "The administrator username for SSH access to the VM."
  default     = "azureuser"
}

variable "ssh_public_key_path" {
  type        = string
  description = "The local absolute or relative path to the public key to authorize on the VM."
  default     = "~/.ssh/id_rsa.pub"
}

variable "os_disk_size_gb" {
  type        = number
  description = "The size of the OS disk in GB."
  default     = 30
}
