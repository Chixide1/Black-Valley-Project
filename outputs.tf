output "ipaddress_azure" {
  value = azurerm_public_ip.public_ip_vm.ip_address
}

output "ipaddress_aws" {
  value = aws_instance.instance.public_ip
}