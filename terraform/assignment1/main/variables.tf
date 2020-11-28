variable "image_name" {
    type = string
    description = "The os that will be installed on the VM"
    default = "ubuntu-2004-focal-v20201028"
}

variable "location_name" {
    type = string
    default = "North Europe"
}

variable "username" {
    type = string
    default = "azureuser"
}

variable "address_space" {
    type = string
    description = "The address space of the virual network"
    default = "10.0.0.0/16"
}

variable "subnet_address_prefixes" {
    type = string
    description = "The address prefixes for the subnet"
    default = "10.0.2.0/24"
}

variable "publicip_number" {
    type = number
    description = "The number of public ips you want"
}

variable "instance_number" {
    type = number
    description = "The number of VM instances you want created"
}

variable "network_interface_number" {
    type = number
    description = "The number of network intarface you want"
}

variable "vm_size" {
    type = string
    description = "The size of the VM(s) to be created"
    default = "Standard_D2s_v3"
}