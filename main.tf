provider "aws" {
  access_key = var.AWS_ACCESS_KEY
  secret_key = var.AWS_SECRET_KEY
  region = var.AWS_REGION
}

provider "azurerm" {
  features {}
}

#AWS
resource "aws_vpc" "virtpc" {
  cidr_block = "192.168.0.0/24"

  tags = {
    "Name" = "bv-vpc"
  }
}

resource "aws_subnet" "subnet" {
  vpc_id = aws_vpc.virtpc.id
  cidr_block = "192.168.0.0/25"
  availability_zone = "eu-west-2b"

  tags = {
    "Name" = "bv-vpc"
  }
}

resource "aws_network_interface" "netint" {
  subnet_id = aws_subnet.subnet.id
}

resource "aws_key_pair" "ssh" {
  key_name = "bv"
  public_key = file("aws-ssh.pub")
}
resource "aws_instance" "vm-aws" {
  ami = "ami-0fbec3e0504ee1970"
  instance_type = "t2.micro"

  network_interface {
    device_index = 0
    network_interface_id = aws_network_interface.netint.id
  }

  key_name = aws_key_pair.ssh.key_name
  
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

resource "azurerm_virtual_machine" "vm" {
  name = "bv-vm"
  resource_group_name = azurerm_resource_group.rg.name
  location = "westeurope"
  vm_size = "Standard_B1s"

  network_interface_ids = [ azurerm_network_interface.nic.id ]

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }
  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
}

