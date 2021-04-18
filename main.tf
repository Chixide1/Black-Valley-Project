provider "aws" {
  region = "eu-west-2"
}

provider "azurerm" {
  features {}
}

#AWS
resource "aws_instance" "vm-aws" {
  ami = "ami-0fbec3e0504ee1970"
  instance_type = "t2.micro"

  tags = {
    "Name" = "bv-i"
  }
}


#Azure
resource "azurerm_resource_group" "rg" {
  name = "black-valley"
  location = "westeurope"
}

resource "azurerm_virtual_network" "vn-azure" {
  name = "bv-vn"
  address_space = [ "192.168.1.0/24" ]
  location = "westeurope"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_storage_account" "sa" {
  name = "blackvalleystor"
  resource_group_name = azurerm_resource_group.rg.name
  location = "westeurope"
  account_tier = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_subnet" "sn" {
  name = "bv-sn"
  resource_group_name = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vn-azure.name
  address_prefixes = [ "192.168.1.0/25" ]
}

resource "azurerm_network_interface" "nic" {
  name = "bv-nic"
  resource_group_name = azurerm_resource_group.rg.name
  location = "westeurope"

  ip_configuration {
    name = "bv-nic"
    subnet_id = azurerm_subnet.sn.id
    private_ip_address_allocation = "dynamic"
  }
}