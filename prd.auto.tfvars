project = {
  proj = {
    env  = "prd"
    name = "tcns"
  }
  rg = {
    location = "northcentralus"
    name     = "rg-loadbalanced-webserver"
  }
}

vm_extension_params = {
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"
}

vm_os_disk = {
  caching              = "ReadWrite"
  storage_account_type = "Standard_LRS"
}

vm_source_image_reference = {
  publisher = "Canonical"
  offer     = "UbuntuServer"
  sku       = "16.04-LTS"
  version   = "latest"
}
