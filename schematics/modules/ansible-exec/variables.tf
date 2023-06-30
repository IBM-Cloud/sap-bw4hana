variable "PLAYBOOK" {
    type = string
    description = "Path to the Ansible Playbook"
}

variable "BASTION_FLOATING_IP" {
    type = string
    description = "IP used to execute the remote script"
}

variable "IP" {
    type = string
    description = "IP used by ansible"
}

variable "PRIVATE_SSH_KEY" {
    type = string
    description = "Private ssh key"
}

locals {

SAP_DEPLOYMENT = "sap-bw4hana"

}
