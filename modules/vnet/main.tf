terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }

  required_version = ">= 1.1.0"
}

resource "azurerm_virtual_network" "deployment" {
  name                = "vnet-${var.proj.name}-${var.proj.env}"
  address_space       = ["10.0.0.0/28"]
  location            = var.rg.location
  resource_group_name = var.rg.name
}

resource "azurerm_subnet" "deployment-web" {
  name                 = "subnet-web-${var.proj.name}-${var.proj.env}"
  resource_group_name  = var.rg.name
  virtual_network_name = azurerm_virtual_network.deployment.name
  address_prefixes     = ["10.0.0.0/29"]
}

resource "azurerm_subnet" "deployment-lb" {
  name                 = "subnet-lb-${var.proj.name}-${var.proj.env}"
  resource_group_name  = var.rg.name
  virtual_network_name = azurerm_virtual_network.deployment.name
  address_prefixes     = ["10.0.0.8/29"]
}

resource "azurerm_public_ip" "deployment" {
  name                = "pubIP-${var.proj.name}-${var.proj.env}"
  resource_group_name = var.rg.name
  location            = var.rg.location
  allocation_method   = "Static"
}

output "public_ip" {
  value = azurerm_public_ip.deployment.id
}

output "vm_subnet_id" {
  value = azurerm_subnet.deployment-web.id
}

output "lb_subnet_id" {
  value = azurerm_subnet.deployment-lb.id
}
