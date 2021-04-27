###AWS###
variable AWS_ACCESS_KEY {}
variable AWS_SECRET_KEY {}
variable "AWS_REGION" {
  default = "eu-west-2"
}


###AZURE###
variable "AZURE_SUBSCRIPTION_ID" {}
variable "AZURE_TENANT_ID" {}
variable "AZURE_CLIENT_SECRET" {}
variable "AZURE_CLIENT_ID" {}
variable "AZURE_REGION" {
  type = string
  default = "westeurope"
}