#Azure resources

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
  location = azurerm_resource_group.rg.location
  account_tier = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_subnet" "sn" {
  name = "bv-sn"
  resource_group_name = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vn-azure.name
  address_prefixes = [ "192.168.1.0/25" ]
}


resource "azurerm_public_ip" "public_ip_vm" {
  name                = "public_ip_vm"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  allocation_method = "Static"
}

resource "azurerm_network_interface" "nic" {
  name = "bv-nic"
  resource_group_name = azurerm_resource_group.rg.name
  location = "westeurope"

  ip_configuration {
    name = "bv-nic"
    subnet_id = azurerm_subnet.sn.id
    private_ip_address_allocation = "dynamic"
    public_ip_address_id = azurerm_public_ip.public_ip_vm.id
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = "vm"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  size                = "Standard_Av2"
  admin_username      = "ubuntu"

  network_interface_ids = [
    azurerm_network_interface.nic.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  admin_ssh_key {
    username   = "ubuntu"
    public_key = file("aws-ssh.pub")
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

