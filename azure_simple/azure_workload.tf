data "template_file" "cloudconfig" {
  #count    = "${var.workload_count}"
  template = "${file("${path.module}${var.CloudinitscriptPath}")}"

  #vars {
  #  hostname = "workload${count.index + 1}.lab"
  #  number   = "${count.index + 1}"
  #}
}

#https://www.terraform.io/docs/providers/template/d/cloudinit_config.html
data "template_cloudinit_config" "config" {
  gzip          = true
  base64_encode = true

  part {
    content = "${data.template_file.cloudconfig.rendered}"
  }
}

resource "azurerm_public_ip" "workloadpip" {
  count                        = "${var.workload_count}"
  name                         = "${var.prefix}-workload${count.index+1}-ip"
  location                     = "${var.azure_region}"
  resource_group_name          = "${data.azurerm_resource_group.my_rg.name}"
  allocation_method            = "Dynamic"
  #domain_name_label            = "${var.dns_name}"
  tags {
    environment = "${var.prefix}"
  }
}

resource "azurerm_network_interface" "workloadnic" {
  count               = "${var.workload_count}"
  name                = "${var.prefix}-workload${count.index+1}-nic"
  location            = "${var.azure_region}"
  resource_group_name = "${data.azurerm_resource_group.my_rg.name}"
  network_security_group_id = "${azurerm_network_security_group.nsginternal.id}"
  ip_configuration {
    name                          = "${var.prefix}-workload${count.index+1}-ipconfig"
    subnet_id                     = "${azurerm_subnet.serversubnet.id}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "${azurerm_public_ip.workloadpip.*.id[count.index]}"
  }
  tags {
    environment = "${var.prefix}"
  }
}

resource "azurerm_virtual_machine" "workload" {
  count               = "${var.workload_count}"
  name                  = "${var.prefix}-workload${count.index+1}"
  location              = "${data.azurerm_resource_group.my_rg.location}"
  resource_group_name   = "${data.azurerm_resource_group.my_rg.name}"
  vm_size               = "${var.workload_size}"
  network_interface_ids = ["${azurerm_network_interface.workloadnic.*.id[count.index]}"]

  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "workload${count.index+1}osdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "workload${count.index+1}"
    admin_username = "${var.admin_user}"
    admin_password = "${var.admin_pass}"
    custom_data    = "${data.template_cloudinit_config.config.rendered}"
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
