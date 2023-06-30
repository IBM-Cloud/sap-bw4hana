module "pre-init" {
  source		= "./modules/pre-init"
}

module "precheck-ssh-exec" {
  source		= "./modules/precheck-ssh-exec"
  depends_on	= [ module.pre-init ]
  BASTION_FLOATING_IP = var.BASTION_FLOATING_IP
  PRIVATE_SSH_KEY = var.PRIVATE_SSH_KEY
  HOSTNAME		= var.DB_HOSTNAME
  SECURITY_GROUP = var.SECURITY_GROUP
}

module "vpc-subnet" {
  source		= "./modules/vpc/subnet"
  depends_on	= [ module.precheck-ssh-exec ]
  ZONE			= var.ZONE
  VPC			= var.VPC
  SECURITY_GROUP = var.SECURITY_GROUP
  SUBNET		= var.SUBNET
}

module "db-vsi" {
  source		= "./modules/db-vsi"
  depends_on	= [ module.precheck-ssh-exec ]
  ZONE			= var.ZONE
  VPC			= var.VPC
  SECURITY_GROUP = var.SECURITY_GROUP
  SUBNET		= var.SUBNET
  HOSTNAME		= var.DB_HOSTNAME
  PROFILE		= var.DB_PROFILE
  IMAGE			= var.DB_IMAGE
  RESOURCE_GROUP = var.RESOURCE_GROUP
  SSH_KEYS		= var.SSH_KEYS
}

module "app-vsi" {
  source		= "./modules/app-vsi"
  depends_on	= [ module.db-vsi ]
  ZONE			= var.ZONE
  VPC			= var.VPC
  SECURITY_GROUP = var.SECURITY_GROUP
  SUBNET		= var.SUBNET
  HOSTNAME		= var.APP_HOSTNAME
  PROFILE		= var.APP_PROFILE
  IMAGE			= var.APP_IMAGE
  RESOURCE_GROUP = var.RESOURCE_GROUP
  SSH_KEYS		= var.SSH_KEYS
  VOLUME_SIZES	= [ "40" , "128" ]
  VOL_PROFILE	= "10iops-tier"

}

module "db-ansible-exec" {
  source		= "./modules/ansible-exec"
  depends_on	= [ module.db-vsi , local_file.db_ansible_saphana-vars, local_file.tf_ansible_hana_storage_generated_file ]
  IP			= module.db-vsi.PRIVATE-IP
  PLAYBOOK = "saphana.yml"
  BASTION_FLOATING_IP = var.BASTION_FLOATING_IP
  PRIVATE_SSH_KEY = var.PRIVATE_SSH_KEY
}

module "app-ansible-exec" {
  source		= "./modules/ansible-exec"
  depends_on	= [ module.db-ansible-exec , module.app-vsi , local_file.app_ansible_bw4app-vars ]
  IP			= module.app-vsi.PRIVATE-IP
  PLAYBOOK = "bw4app.yml"
  BASTION_FLOATING_IP = var.BASTION_FLOATING_IP
  PRIVATE_SSH_KEY = var.PRIVATE_SSH_KEY
}
