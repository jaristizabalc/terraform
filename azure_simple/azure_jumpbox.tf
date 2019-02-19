resource "azurerm_network_interface" "jumpboxnic" {
  name                = "${var.prefix}-jumpbox-nic"
  location            = "${var.azure_region}"
  resource_group_name = "${data.azurerm_resource_group.my_rg.name}"
  network_security_group_id = "${azurerm_network_security_group.nsgexternal.id}"
  ip_configuration {
    name                          = "${var.prefix}-jumpbox-ipconfig"
    subnet_id                     = "${azurerm_subnet.mgmtsubnet.id}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "${azurerm_public_ip.jumpboxpip.id}"
  }
  tags {
    environment = "${var.prefix}"
  }
}

resource "azurerm_public_ip" "jumpboxpip" {
  name                         = "${var.prefix}-jumpbox-ip"
  location                     = "${var.azure_region}"
  resource_group_name          = "${data.azurerm_resource_group.my_rg.name}"
  allocation_method            = "Dynamic"
  #domain_name_label            = "${var.dns_name}"
  tags {
    environment = "${var.prefix}"
  }
}
resource "azurerm_virtual_machine" "jumpbox" {
  name                  = "${var.prefix}-jumpbox"
  location              = "${data.azurerm_resource_group.my_rg.location}"
  resource_group_name   = "${data.azurerm_resource_group.my_rg.name}"
  vm_size               = "${var.jumpbox_size}"
  network_interface_ids = ["${azurerm_network_interface.jumpboxnic.id}"]
  
  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true
  depends_on = ["azurerm_network_interface.jumpboxnic"]

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "jumpboxosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "jumpbox"
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
