# Using existing resource group
data "azurerm_resource_group" "my_rg" {
  name = "${var.azure_existing_rg}"
}

resource "azurerm_virtual_network" "mainvnet" {
  name                = "fse-juan-aristizabal-terraform-vnet"
  resource_group_name = "${data.azurerm_resource_group.my_rg.name}"
  location            = "${var.azure_region}"
  address_space       = ["${var.vnet_cidr}"]
}

resource "azurerm_subnet" "mgmtsubnet" {
  name                 = "mgmt_subnet"
  resource_group_name  = "${data.azurerm_resource_group.my_rg.name}"
  virtual_network_name = "${azurerm_virtual_network.mainvnet.name}"
  address_prefix       = "${cidrsubnet(var.vnet_cidr, 2, 0)}"
}
resource "azurerm_subnet" "serversubnet" {
  name                 = "server_subnet"
  resource_group_name  = "${data.azurerm_resource_group.my_rg.name}"
  virtual_network_name = "${azurerm_virtual_network.mainvnet.name}"
  address_prefix       = "${cidrsubnet(var.vnet_cidr, 2, 1)}"
}
resource "azurerm_subnet" "vipsubnet" {
  name                 = "vip_subnet"
  resource_group_name  = "${data.azurerm_resource_group.my_rg.name}"
  virtual_network_name = "${azurerm_virtual_network.mainvnet.name}"
  address_prefix       = "${cidrsubnet(var.vnet_cidr, 2, 2)}"
}
resource "azurerm_storage_account" "storageaccount" {
  name                     = "storacctf${var.prefix}"
  location                 = "${var.azure_region}"
  resource_group_name      = "${data.azurerm_resource_group.my_rg.name}"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
resource "azurerm_network_security_group" "nsgexternal" {
  name                = "nsg_external_access"
  location            = "${var.azure_region}"
  resource_group_name = "${data.azurerm_resource_group.my_rg.name}"

}
resource "azurerm_network_security_group" "nsginternal" {
  name                = "nsg_internal_access"
  location            = "${var.azure_region}"
  resource_group_name = "${data.azurerm_resource_group.my_rg.name}"

}

resource "azurerm_network_security_rule" "sshrule" {
  name                        = "ssh_in"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${data.azurerm_resource_group.my_rg.name}"
  network_security_group_name = "${azurerm_network_security_group.nsgexternal.name}"
}
resource "azurerm_network_security_rule" "httprule" {
  name                        = "http_in"
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${data.azurerm_resource_group.my_rg.name}"
  network_security_group_name = "${azurerm_network_security_group.nsgexternal.name}"
}
resource "azurerm_network_security_rule" "httpsrule" {
  name                        = "https_in"
  priority                    = 102
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${data.azurerm_resource_group.my_rg.name}"
  network_security_group_name = "${azurerm_network_security_group.nsgexternal.name}"
}
