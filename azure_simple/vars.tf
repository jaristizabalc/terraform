variable "azure_subscription_id" {default = "77d6aa12-ef65-44f8-b9f5-07e7f7e8b48b"}
variable "azure_client_id" {default = "0de40697-72c4-482e-903e-8d41fb1747ae"}
variable "azure_client_secret"  {default = "dssvNfW3WW2e3aMnDBz10vOfzCH/AGvp+zMpXgWGJuw="}
variable "azure_tenant_id" {default = "07f53873-c252-4521-8c71-591a3d5b42b6"}
variable "azure_region" {default= "East US"}
variable "azure_existing_rg" {default= "fse-juan.aristizabal-rg"}
variable "prefix" {default= "jdat3"}
variable "admin_user" {default= "aviadmin"}
variable "admin_pass" {default= "AviNetworks123!"}
variable "workload_count" {
  description = "Number of workload servers"
  default     = 2
}
variable "CloudinitscriptPath" {default= "/userdata/workload_init.sh"}
