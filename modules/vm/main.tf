terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }

  required_version = ">= 1.1.0"
}

resource "azurerm_availability_set" "deployment" {
  name                = "availabilityset-${var.proj.name}-${var.proj.env}"
  resource_group_name = var.rg.name
  location            = var.rg.location
}

resource "azurerm_network_interface" "deployment" {
  count = length(var.vm_list)

  name                = "nic-${var.proj.name}-${var.proj.env}-${count.index}"
  location            = var.rg.location
  resource_group_name = var.rg.name

  ip_configuration {
    name                          = "nic-${var.proj.name}-${var.proj.env}-${count.index}-ipconfig"
    subnet_id                     = var.vm_subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface_backend_address_pool_association" "deployment" {
  count = length(var.vm_list)

  network_interface_id    = element(azurerm_network_interface.deployment, count.index).id
  ip_configuration_name   = element(azurerm_network_interface.deployment, count.index).ip_configuration[0].name
  backend_address_pool_id = var.backend_address_pool_id
}

resource "azurerm_linux_virtual_machine" "deployment" {
  for_each = var.vm_list

  name                            = "vm-${each.key}-${var.proj.name}-${var.proj.env}"
  resource_group_name             = var.rg.name
  location                        = var.rg.location
  size                            = each.value.sku_size
  availability_set_id             = azurerm_availability_set.deployment.id
  admin_username                  = each.value.admin_name
  admin_password                  = each.value.admin_pass
  disable_password_authentication = false

  network_interface_ids = [
    element(azurerm_network_interface.deployment, index(keys(var.vm_list), each.key)).id,
  ]

  os_disk {
    caching              = each.value.os_disk.caching
    storage_account_type = each.value.os_disk.storage_account_type
  }

  source_image_reference {
    publisher = each.value.source_image_reference.publisher
    offer     = each.value.source_image_reference.offer
    sku       = each.value.source_image_reference.sku
    version   = each.value.source_image_reference.version
  }
}

resource "azurerm_virtual_machine_extension" "deployment" {
  for_each = var.vm_list

  name                 = "vmex-${each.key}-${var.proj.name}-${var.proj.env}"
  virtual_machine_id   = azurerm_linux_virtual_machine.deployment[each.key].id
  publisher            = var.vm_extension.publisher
  type                 = var.vm_extension.type
  type_handler_version = var.vm_extension.type_handler_version
}
