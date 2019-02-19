# This file contains various variables that affect the configuration of the deployed infrastructure
#

variable "vnet_cidr" {
  description = "Primary CIDR block for VNET"
  default     = "10.60.3.0/24"
}
variable "jumpbox_size" {
  description = "Jumpbox size"
  default = "Standard_DS1_v2"
}
variable "controller_size" {
  description = "AVI Controller size"
  default = "Standard_D8s_v3"
}
variable "workload_size" {
  description = "Workload VM size"
  default = "Standard_B1ms"
}
