terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }

  required_version = ">= 1.1.0"
}

resource "azurerm_lb" "deployment" {
  name                = "lb-${var.proj.name}-${var.proj.env}"
  resource_group_name = var.rg.name
  location            = var.rg.location
  frontend_ip_configuration {
    name                 = "lb-${var.proj.name}-${var.proj.env}-ip"
    public_ip_address_id = var.public_ip_address_id
  }
}

resource "azurerm_lb_backend_address_pool" "deployment" {
  loadbalancer_id = azurerm_lb.deployment.id
  name            = "${azurerm_lb.deployment.name}-pool"
}

resource "azurerm_lb_probe" "deployment" {
  name            = "${azurerm_lb.deployment.name}-probe"
  loadbalancer_id = azurerm_lb.deployment.id
  port            = 80
}

resource "azurerm_lb_rule" "deployment" {
  name                           = "${azurerm_lb.deployment.name}-rule"
  loadbalancer_id                = azurerm_lb.deployment.id
  frontend_ip_configuration_name = azurerm_lb.deployment.frontend_ip_configuration[0].name
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  backend_address_pool_ids       = ["${azurerm_lb_backend_address_pool.deployment.id}"]
  probe_id                       = azurerm_lb_probe.deployment.id
}

output "backend_address_pool_id" {
  value = azurerm_lb_backend_address_pool.deployment.id
}
