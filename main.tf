# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }
  backend "azurerm" {
    resource_group_name  = "rg-loadbalanced-webserver"
    storage_account_name = "tcnstfstate"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
}

module "rg" {
  source = "./modules/rg"

  proj = var.project.proj
  rg   = var.project.rg
}

module "vnet" {
  source = "./modules/vnet"

  proj = var.project.proj
  rg   = var.project.rg
}

module "lb" {
  source = "./modules/lb"

  proj                 = var.project.proj
  rg                   = var.project.rg
  public_ip_address_id = module.vnet.public_ip
}

module "vm" {
  source = "./modules/vm"

  proj                    = var.project.proj
  rg                      = var.project.rg
  vm_subnet_id            = module.vnet.vm_subnet_id
  backend_address_pool_id = module.lb.backend_address_pool_id
  vm_extension            = var.vm_extension_params

  vm_list = {
    main = {
      admin_name             = "admin-main"
      admin_pass             = file("./mypass.txt")
      os_disk                = var.vm_os_disk
      sku_size               = "Standard_B1s"
      source_image_reference = var.vm_source_image_reference
    }

    aux = {
      admin_name             = "admin-aux"
      admin_pass             = file("./mypass.txt")
      os_disk                = var.vm_os_disk
      sku_size               = "Standard_DS1_v2"
      source_image_reference = var.vm_source_image_reference
    }

    bak = {
      admin_name             = "admin-bak"
      admin_pass             = file("./mypass.txt")
      os_disk                = var.vm_os_disk
      sku_size               = "Standard_DS1_v2"
      source_image_reference = var.vm_source_image_reference
    }
  }
}

resource "azurerm_storage_account" "tfstate" {
  name                     = "tcnstfstate"
  resource_group_name      = var.project.rg.name
  location                 = var.project.rg.location
  account_kind             = "BlobStorage"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "tfstate" {
  name                 = "tfstate"
  storage_account_name = "tcnstfstate"
}
