variable "project" {
  type = object({
    proj = object({
      name = string
      env  = string
    })
    rg = object({
      name     = string
      location = string
    })
  })
}

variable "vm_extension_params" {
  type = object({
    publisher            = string
    type                 = string
    type_handler_version = string
  })
}

variable "vm_os_disk" {
  type = object({
    caching              = string
    storage_account_type = string
  })
}

variable "vm_source_image_reference" {
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
}
