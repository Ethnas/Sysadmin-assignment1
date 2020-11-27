variable "image_name" {
    type = string
    description = "The os that will be installed on the VM"
    default = "ubuntu-2004-focal-v20201028"
}

variable "project_name" {
    type = string
    default = "test-ansible"
}

variable "region_name" {
    type = string
    default = "europe-north1"
}

variable "zone_name" {
    type = string
    default = "europe-north1-a"
}

variable "username" {
    type = string
    default = "erlendniko@gmail.com"
}