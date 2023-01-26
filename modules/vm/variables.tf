variable "proj" {
  type = object({
    name = string
    env  = string
  })
}

variable "rg" {
  type = object({
    name     = string
    location = string
  })
}

variable "vm_subnet_id" {
  type = string
}

variable "backend_address_pool_id" {
  type = string
}

variable "vm_list" {
  # key is the vm name
  type = map(object({
    sku_size   = string
    admin_name = string
    admin_pass = string

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
  }))
}

variable "vm_extension" {
  type = object({
    publisher            = string
    type                 = string
    type_handler_version = string
  })
}
