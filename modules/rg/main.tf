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
  name     = var.rg.name
  location = var.rg.location
}

resource "azurerm_key_vault" "deployment" {
  name                = "kv-${var.proj.name}-${var.proj.env}"
  location            = azurerm_resource_group.deployment.location
  resource_group_name = azurerm_resource_group.deployment.name
  sku_name            = "standard"
  tenant_id           = data.azurerm_client_config.current.tenant_id
}
