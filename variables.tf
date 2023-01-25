variable "resource_group_name" {
  type    = string
  default = "rg-tftraining-nstem"
}

variable "resource_location_name" {
  type    = string
  default = "eastus"
}

variable "az_portal_pass" {
  type    = string
  default = "mypassword123"
}

variable "web_server_deployment" {
  type = object({
    vnet_name         = string
    subnet_web_name   = string
    subnet_lb_name    = string
    nic_name          = string
    nic_ipconfig_name = string
    vm_name           = string
  })
}

variable "vm_list" {
  type = map(object({
    size       = string
    admin_name = string
    NIC_index  = number
  }))
}

variable "vm_params" {
  type = object({
    size       = string
    admin_name = string
    count      = number

    os_disk = object({
      caching              = string
      storage_account_type = string
    })

    source_image_reference = object({
      publisher = string
      offer     = string
      sku       = string
      version   = string
    })

    extension = object({
      name                 = string
      publisher            = string
      type                 = string
      type_handler_version = string
    })
  })
}

variable "lb_params" {
  type = object({
    name                      = string
    public_ip_name            = string
    public_ip_allocation      = string
    rule                      = string
    probe                     = string
    frontend_ipconfig_name    = string
    backend_pool_name         = string
    backend_pool_address_name = string
  })
}

variable "kv_params" {
  type = object({
    name     = string
    sku_name = string
  })
}
