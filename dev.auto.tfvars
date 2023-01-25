resource_group_name    = "rg-tftraining-nstem-fulldeployment"
resource_location_name = "eastus"

web_server_deployment = {
  vnet_name         = "tcns-vnet"
  subnet_web_name   = "tcns-web-net"
  subnet_lb_name    = "tcns-lb-net"
  nic_name          = "tcns-vm-nic"
  nic_ipconfig_name = "tcns-vm-nic-ipconfig"
  vm_name           = "tcns-vm"
}

vm_params = {
  size       = "Standard_A1_v2"
  admin_name = "web-vm-admin"
  count      = 2

  os_disk = {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference = {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  extension = {
    name                 = "tcns-vm-extension"
    publisher            = "Microsoft.Azure.Extensions"
    type                 = "CustomScript"
    type_handler_version = "2.0"
  }
}

vm_list = {
  VM1 = {
    admin_name = "web-vm-admin"
    size       = "Standard_B1s"
    NIC_index  = 0
  }
  VM2 = {
    admin_name = "api-vm-admin"
    size       = "Standard_DS1_v2"
    NIC_index  = 1
  }
}

lb_params = {
  name                      = "tcns-lb"
  public_ip_name            = "tcns-lb-ip"
  public_ip_allocation      = "Static"
  rule                      = "tcns-lb-rule"
  probe                     = "tcns-lb-probe"
  frontend_ipconfig_name    = "tcns-lb-frontendipconfig"
  backend_pool_name         = "tcns-lb-backendpool"
  backend_pool_address_name = "tcns-lb-backendpool-address"
}

kv_params = {
  name     = "tcns-kv"
  sku_name = "standard"
}
