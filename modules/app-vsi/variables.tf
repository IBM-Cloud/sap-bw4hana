variable "ZONE" {
    type = string
    description = "Cloud Zone"
}

variable "VPC" {
    type = string
    description = "VPC name"
}

variable "SUBNET" {
    type = string
    description = "Subnet name"
}

variable "SECURITY_GROUP" {
    type = string
    description = "Security group name"
}

variable "RESOURCE_GROUP" {
    type = string
    description = "Resource Group"
}

variable "HOSTNAME" {
    type = string
    description = "VSI Hostname"
}

variable "PROFILE" {
    type = string
    description = "VSI Profile"
}

variable "VOL_PROFILE" {
    type = string
    description = "VSI Profile"
}

variable "IMAGE" {
    type = string
    description = "VSI OS Image"
}

variable "SSH_KEYS" {
    type = list(string)
    description = "List of SSH Keys to access the VSI"
}

variable "VOLUME_SIZE" {
    type = string
    description = "List of volume sizes in GB to be created"
}

locals {
    RAM_SIZE = tonumber(split("x", split("-", var.PROFILE)[1])[1])
    RANGES = jsondecode(file("${path.module}/files/swap_size.json"))
    SWAP_list = [
        for range in local.RANGES : range.swap_size
            if (
            (range.ram_min == null || local.RAM_SIZE >= range.ram_min) && 
            (range.ram_max == null || local.RAM_SIZE <= range.ram_max)
            ) 
    ]
    SWAP_size = local.SWAP_list[0]
    VOLUME_SIZES = [local.SWAP_size, var.VOLUME_SIZE]
}
