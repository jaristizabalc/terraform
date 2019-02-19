resource "azurerm_network_interface" "controllernic" {
  name                = "${var.prefix}-controller-nic"
  location            = "${var.azure_region}"
  resource_group_name = "${data.azurerm_resource_group.my_rg.name}"
  network_security_group_id = "${azurerm_network_security_group.nsgexternal.id}"
  ip_configuration {
    name                          = "${var.prefix}-controller-ipconfig"
    subnet_id                     = "${azurerm_subnet.mgmtsubnet.id}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "${azurerm_public_ip.controllerpip.id}"
  }
  tags {
    environment = "${var.prefix}"
  }
}

resource "azurerm_public_ip" "controllerpip" {
  name                         = "${var.prefix}-controller-ip"
  location                     = "${var.azure_region}"
  resource_group_name          = "${data.azurerm_resource_group.my_rg.name}"
  allocation_method            = "Dynamic"
  #domain_name_label            = "${var.dns_name}"
  tags {
    environment = "${var.prefix}"
  }
}
resource "azurerm_virtual_machine" "controller" {
  name                  = "${var.prefix}-controller"
  location              = "${data.azurerm_resource_group.my_rg.location}"
  resource_group_name   = "${data.azurerm_resource_group.my_rg.name}"
  vm_size               = "${var.controller_size}"
  network_interface_ids = ["${azurerm_network_interface.controllernic.id}"]
 
#  depends_on             = ["azurerm_virtual_machine.jumpbox"]
 
  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true


  storage_image_reference {
    publisher = "avi-networks"
    offer     = "avi-vantage-adc"
    sku       = "avi-vantage-adc-1801"
    version   = "18.01.05"
  }

  plan {
    name = "avi-vantage-adc-1801"
    publisher = "avi-networks"
    product = "avi-vantage-adc"
  }

  storage_os_disk {
    name              = "controllerosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "controller"
    admin_username = "${var.admin_user}"
    admin_password = "${var.admin_pass}"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
  boot_diagnostics {
    enabled     = true
    storage_uri = "${azurerm_storage_account.storageaccount.primary_blob_endpoint}"
  }
  tags {
    environment = "${var.prefix}"
  }

}
