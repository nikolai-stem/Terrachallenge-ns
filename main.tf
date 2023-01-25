# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "deployment" {
  name     = var.resource_group_name
  location = var.resource_location_name
}

# Full deployment
resource "azurerm_virtual_network" "deployment" {
  name                = var.web_server_deployment.vnet_name
  address_space       = ["10.0.0.0/28"]
  location            = azurerm_resource_group.deployment.location
  resource_group_name = azurerm_resource_group.deployment.name
}

resource "azurerm_subnet" "deployment-web" {
  name                 = var.web_server_deployment.subnet_web_name
  resource_group_name  = azurerm_resource_group.deployment.name
  virtual_network_name = azurerm_virtual_network.deployment.name
  address_prefixes     = ["10.0.0.0/29"]
}

resource "azurerm_subnet" "deployment-lb" {
  name                 = var.web_server_deployment.subnet_lb_name
  resource_group_name  = azurerm_resource_group.deployment.name
  virtual_network_name = azurerm_virtual_network.deployment.name
  address_prefixes     = ["10.0.0.8/29"]
}

resource "azurerm_network_interface" "deployment" {
  name                = var.web_server_deployment.nic_name
  location            = azurerm_resource_group.deployment.location
  resource_group_name = azurerm_resource_group.deployment.name

  ip_configuration {
    name                          = var.web_server_deployment.nic_ipconfig_name
    subnet_id                     = azurerm_subnet.deployment-web.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_public_ip" "deployment" {
  name                = var.lb_params.public_ip_name
  resource_group_name = azurerm_resource_group.deployment.name
  location            = azurerm_resource_group.deployment.location
  allocation_method   = var.lb_params.public_ip_allocation
}

resource "azurerm_lb" "deployment" {
  name                = var.lb_params.name
  resource_group_name = azurerm_resource_group.deployment.name
  location            = azurerm_resource_group.deployment.location
  frontend_ip_configuration {
    name                 = var.lb_params.frontend_ipconfig_name
    public_ip_address_id = azurerm_public_ip.deployment.id
  }
}

resource "azurerm_lb_backend_address_pool" "deployment" {
  loadbalancer_id = azurerm_lb.deployment.id
  name            = var.lb_params.backend_pool_name
}

resource "azurerm_lb_rule" "deployment" {
  name                           = var.lb_params.rule
  loadbalancer_id                = azurerm_lb.deployment.id
  frontend_ip_configuration_name = azurerm_lb.deployment.frontend_ip_configuration[0].name
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  backend_address_pool_ids       = ["${azurerm_lb_backend_address_pool.deployment.id}"]
  probe_id                       = azurerm_lb_probe.deployment.id
}

resource "azurerm_lb_probe" "deployment" {
  name            = var.lb_params.probe
  loadbalancer_id = azurerm_lb.deployment.id
  port            = 80
}

resource "azurerm_network_interface_backend_address_pool_association" "deployment" {
  network_interface_id    = azurerm_network_interface.deployment.id
  ip_configuration_name   = azurerm_network_interface.deployment.ip_configuration[0].name
  backend_address_pool_id = azurerm_lb_backend_address_pool.deployment.id
}

resource "azurerm_linux_virtual_machine" "deployment" {
  name                = var.web_server_deployment.vm_name
  resource_group_name = azurerm_resource_group.deployment.name
  location            = azurerm_resource_group.deployment.location
  size                = var.vm_params.size

  admin_username                  = var.vm_params.admin_name
  admin_password                  = file("./mypass.txt")
  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.deployment.id,
  ]

  os_disk {
    caching              = var.vm_params.os_disk.caching
    storage_account_type = var.vm_params.os_disk.storage_account_type
  }

  source_image_reference {
    publisher = var.vm_params.source_image_reference.publisher
    offer     = var.vm_params.source_image_reference.offer
    sku       = var.vm_params.source_image_reference.sku
    version   = var.vm_params.source_image_reference.version
  }
}

resource "azurerm_key_vault" "deployment" {
  name                = var.kv_params.name
  location            = azurerm_resource_group.deployment.location
  resource_group_name = azurerm_resource_group.deployment.name
  sku_name            = var.kv_params.sku_name
  tenant_id           = data.azurerm_client_config.current.tenant_id
}

resource "azurerm_virtual_machine_extension" "deployment" {
  name                 = var.vm_params.extension.name
  virtual_machine_id   = azurerm_linux_virtual_machine.deployment.id
  publisher            = var.vm_params.extension.publisher
  type                 = var.vm_params.extension.type
  type_handler_version = var.vm_params.extension.type_handler_version
}
