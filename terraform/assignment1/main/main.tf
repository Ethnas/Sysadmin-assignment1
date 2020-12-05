terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = ">= 2.26"
    }
  }
}

provider "azurerm" {
  version = "=2.38.0"

  subscription_id = "93d67d1d-09d3-4cca-9b39-7cd1ef68c9dd"
  #client_id = "http://azure-cli-2020-11-28-12-13-13"
  #client_secret = "dR_rzbGOZRO~gktL72-nYG3TgR1ZsWNafD"
  #tenant_id = "97a06cc0-13f4-4e3e-a0fe-94153a19823b"

  features {}
}

resource "azurerm_resource_group" "myterraformgroup" {
  name = "myresourcegroup"
  location = var.location_name
}

resource "azurerm_virtual_network" "myterraformnetwork" {
    name = "myVnet"
    address_space = [var.address_space]
    location = var.location_name
    resource_group_name = azurerm_resource_group.myterraformgroup.name
}

resource "azurerm_subnet" "myterraformsubnet" {
    name = "mySubnet"
    resource_group_name = azurerm_resource_group.myterraformgroup.name
    virtual_network_name = azurerm_virtual_network.myterraformnetwork.name
    address_prefixes = [var.subnet_address_prefixes]
}

resource "azurerm_public_ip" "lb_public_ip" {
    name = "lb-public-ip"
    location = var.location_name
    resource_group_name = azurerm_resource_group.myterraformgroup.name
    allocation_method = "Static"
}

resource "azurerm_lb" "lb" {
 name                = "loadBalancer"
 location            = var.location_name
 resource_group_name = azurerm_resource_group.myterraformgroup.name

 frontend_ip_configuration {
   name                 = "publicIPAddress"
   public_ip_address_id = azurerm_public_ip.lb_public_ip.id
 }
}

resource "azurerm_lb_backend_address_pool" "lb_address_pool" {
 resource_group_name = azurerm_resource_group.myterraformgroup.name
 loadbalancer_id     = azurerm_lb.lb.id
 name                = "BackEndAddressPool"
}

resource "azurerm_network_security_group" "myterraformnsg" {
    name = "myNetworkSecurityGroup"
    location = var.location_name
    resource_group_name = azurerm_resource_group.myterraformgroup.name

    security_rule {
        name = "SSH"
        priority = 1001
        direction = "Inbound"
        access = "Allow"
        protocol = "Tcp"
        source_port_range = "*"
        destination_port_range = "22"
        source_address_prefix = "*"
        destination_address_prefix = "*"
    }

    security_rule {
    name                       = "allow-http"
    description                = "allow-http"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "myterraformnic" {
    count = var.network_interface_number
    name = "myNIC-${count.index}"
    location = var.location_name
    resource_group_name = azurerm_resource_group.myterraformgroup.name

    ip_configuration {
        name = "myNicConfiguration"
        subnet_id = azurerm_subnet.myterraformsubnet.id
        private_ip_address_allocation = "Dynamic"
    }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "example" {
    count = var.network_interface_number
    network_interface_id      = element(azurerm_network_interface.myterraformnic.*.id, count.index)
    network_security_group_id = azurerm_network_security_group.myterraformnsg.id
}

resource "azurerm_linux_virtual_machine" "webserver" {
    count = var.webserver_instance_number
    name = "webserver-${count.index}"
    location = var.location_name
    resource_group_name   = azurerm_resource_group.myterraformgroup.name
    network_interface_ids = [element(azurerm_network_interface.myterraformnic.*.id, count.index)]
    size                  = var.vm_size

    os_disk {
        name = "myOsDisk-${count.index}"
        caching = "ReadWrite"
        storage_account_type = "Premium_LRS"
    }

    source_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }

    computer_name  = "webserver-${count.index}"
    admin_username = var.username
    disable_password_authentication = true

    admin_ssh_key {
        username       = var.username
        public_key     = file("id_rsa.pub")
    }

    #Run script for installing Apache web server
    provisioner "remote-exec" {
	    script = "..\\scripts\\apache.sh"
	    connection {
	      type = "ssh"
        host = azurerm_linux_virtual_machine.webserver[count.index].public_ip_address
	      user = var.username
	      timeout = "1m"
	      private_key = file("id_rsa")
	  }
  }
}

# resource "azurerm_linux_virtual_machine" "client" {
#     count = var.client_instance_number
#     name = "client-${count.index}"
#     location = var.location_name
#     resource_group_name   = azurerm_resource_group.myterraformgroup.name
#     network_interface_ids = [element(azurerm_network_interface.myterraformnic.*.id, count.index)]
#     size                  = var.vm_size

#     os_disk {
#         name = "myOsDisk-${count.index}"
#         caching = "ReadWrite"
#         storage_account_type = "Premium_LRS"
#     }

#     source_image_reference {
#         publisher = "Canonical"
#         offer     = "UbuntuServer"
#         sku       = "18.04-LTS"
#         version   = "latest"
#     }

#     computer_name  = "client-${count.index}"
#     admin_username = var.username
#     disable_password_authentication = true

#     admin_ssh_key {
#         username       = var.username
#         public_key     = file("id_rsa.pub")
#     }
# }