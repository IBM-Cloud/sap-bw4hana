module "vpc-subnet" {
  source		= "./modules/vpc/subnet"
  ZONE			= var.ZONE
  VPC			= var.VPC
  SECURITY_GROUP = var.SECURITY_GROUP
  SUBNET		= var.SUBNET
}

module "db-vsi" {
  source		= "./modules/db-vsi"
  ZONE			= var.ZONE
  VPC			= var.VPC
  SECURITY_GROUP = var.SECURITY_GROUP
  SUBNET		= var.SUBNET
  RESOURCE_GROUP = var.RESOURCE_GROUP
  HOSTNAME		= var.DB_HOSTNAME
  PROFILE		= var.DB_PROFILE
  IMAGE			= var.DB_IMAGE
  SSH_KEYS		= var.SSH_KEYS
}

module "app-vsi" {
  source		= "./modules/app-vsi"
  ZONE			= var.ZONE
  VPC			= var.VPC
  SECURITY_GROUP = var.SECURITY_GROUP
  SUBNET		= var.SUBNET
  RESOURCE_GROUP = var.RESOURCE_GROUP
  HOSTNAME		= var.APP_HOSTNAME
  PROFILE		= var.APP_PROFILE
  IMAGE			= var.APP_IMAGE
  SSH_KEYS		= var.SSH_KEYS
  VOLUME_SIZES	= [ "40" , "128" ]
  VOL_PROFILE	= "10iops-tier"

}

module "db-ansible-exec" {
  source		= "./modules/ansible-exec"
  depends_on	= [ module.db-vsi , local_file.db_ansible_saphana-vars, local_file.tf_ansible_hana_storage_generated_file ]
  IP			= module.db-vsi.PRIVATE-IP
  PLAYBOOK_PATH = "ansible/saphana.yml"
}

module "app-ansible-exec" {
  source		= "./modules/ansible-exec"
  depends_on	= [ module.db-ansible-exec , module.app-vsi , local_file.app_ansible_bw4app-vars ]
  IP			= module.app-vsi.PRIVATE-IP
  PLAYBOOK_PATH = "ansible/bw4app.yml"
}

module "sec-exec" {
  source		= "./modules/sec-exec"
  depends_on	= [ module.app-ansible-exec ]
  IP			= module.app-vsi.PRIVATE-IP
  SAP_MAIN_PASSWORD = var.SAP_MAIN_PASSWORD
  HANA_MAIN_PASSWORD = var.HANA_MAIN_PASSWORD
}
