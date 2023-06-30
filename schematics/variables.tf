variable "PRIVATE_SSH_KEY" {
	type		= string
	description = "Input id_rsa private key content"
}

variable "SSH_KEYS" {
	type		= list(string)
	description = "SSH Keys ID list to access the VSI"
	validation {
		condition     = var.SSH_KEYS == [] ? false : true && var.SSH_KEYS == [""] ? false : true
		error_message = "At least one SSH KEY is needed to be able to access the VSI."
	}
}

variable "BASTION_FLOATING_IP" {
	type		= string
	description = "Input the FLOATING IP from the Bastion Server"
}

variable "RESOURCE_GROUP" {
  type        = string
  description = "EXISTING Resource Group for VSIs and Volumes"
  default     = "Default"
}

variable "REGION" {
	type		= string
	description	= "Cloud Region"
	validation {
		condition     = contains(["eu-de", "eu-gb", "us-south", "us-east"], var.REGION )
		error_message = "The REGION must be one of: eu-de, eu-gb, us-south, us-east."
	}
}

variable "ZONE" {
	type		= string
	description	= "Cloud Zone"
	validation {
		condition     = length(regexall("^(eu-de|eu-gb|us-south|us-east)-(1|2|3)$", var.ZONE)) > 0
		error_message = "The ZONE is not valid."
	}
}

variable "VPC" {
	type		= string
	description = "EXISTING VPC name"
	validation {
		condition     = length(regexall("^([a-z]|[a-z][-a-z0-9]*[a-z0-9]|[0-9][-a-z0-9]*([a-z]|[-a-z][-a-z0-9]*[a-z0-9]))$", var.VPC)) > 0
		error_message = "The VPC name is not valid."
	}
}

variable "SUBNET" {
	type		= string
	description = "EXISTING Subnet name"
	validation {
		condition     = length(regexall("^([a-z]|[a-z][-a-z0-9]*[a-z0-9]|[0-9][-a-z0-9]*([a-z]|[-a-z][-a-z0-9]*[a-z0-9]))$", var.SUBNET)) > 0
		error_message = "The SUBNET name is not valid."
	}
}

variable "SECURITY_GROUP" {
	type		= string
	description = "EXISTING Security group name"
	validation {
		condition     = length(regexall("^([a-z]|[a-z][-a-z0-9]*[a-z0-9]|[0-9][-a-z0-9]*([a-z]|[-a-z][-a-z0-9]*[a-z0-9]))$", var.SECURITY_GROUP)) > 0
		error_message = "The SECURITY_GROUP name is not valid."
	}
}

variable "DB_HOSTNAME" {
	type		= string
	description = "DB VSI Hostname"
	validation {
		condition     = length(var.DB_HOSTNAME) <= 13 && length(regexall("^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\\-]*[a-zA-Z0-9])\\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\\-]*[A-Za-z0-9])$", var.DB_HOSTNAME)) > 0
		error_message = "The DB_HOSTNAME is not valid."
	}
}

variable "DB_PROFILE" {
	type		= string
	description = "DB VSI Profile. The certified profiles for SAP HANA in IBM VPC: https://cloud.ibm.com/docs/sap?topic=sap-hana-iaas-offerings-profiles-intel-vs-vpc"
	default		= "mx2-16x128"
	validation {
		condition     = contains(keys(jsondecode(file("files/hana_volume_layout.json")).profiles), "${var.DB_PROFILE}")
		error_message = "The chosen storage PROFILE for HANA VSI \"${var.DB_PROFILE}\" is not a certified storage profile. Please, chose the appropriate certified storage PROFILE for the HANA VSI from  https://cloud.ibm.com/docs/sap?topic=sap-hana-iaas-offerings-profiles-intel-vs-vpc . Make sure the selected PROFILE is certified for the selected OS type and for the proceesing type (SAP Business One, OLTP, OLAP)"
	}
}

variable "DB_IMAGE" {
	type		= string
	description = "DB VSI OS Image"
	default		= "ibm-redhat-8-6-amd64-sap-hana-2"
	validation {
         condition     = length(regexall("^(ibm-redhat-8-(4|6)-amd64-sap-hana|ibm-sles-15-(3|4)-amd64-sap-hana)-[0-9][0-9]*", var.DB_IMAGE)) > 0
             error_message = "The OS SAP DB_IMAGE must be one of  \"ibm-sles-15-3-amd64-sap-hana-x\", \"ibm-sles-15-4-amd64-sap-hana-x\", \"ibm-redhat-8-4-amd64-sap-hana-2\" or \"ibm-redhat-8-6-amd64-sap-hana-x\"."
 }
}
variable "APP_HOSTNAME" {
	type		= string
	description = "APP VSI Hostname"
	validation {
		condition     = length(var.APP_HOSTNAME) <= 13 && length(regexall("^(([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\\-]*[a-zA-Z0-9])\\.)*([A-Za-z0-9]|[A-Za-z0-9][A-Za-z0-9\\-]*[A-Za-z0-9])$", var.APP_HOSTNAME)) > 0
		error_message = "The APP_HOSTNAME is not valid."
	}
}

variable "APP_PROFILE" {
	type		= string
	description = "VSI Profile"
	default		= "bx2-4x16"
}

variable "APP_IMAGE" {
	type		= string
	description = "VSI OS Image"
	default		= "ibm-redhat-8-6-amd64-sap-applications-2"
	validation {
         condition     = length(regexall("^(ibm-redhat-8-(4|6)-amd64-sap-applications|ibm-sles-15-(3|4)-amd64-sap-applications)-[0-9][0-9]*", var.APP_IMAGE)) > 0
             error_message = "The OS SAP APP_IMAGE must be one of \"ibm-redhat-8-4-amd64-sap-applications-x\", \"ibm-redhat-8-6-amd64-sap-applications-x\", \"ibm-sles-15-3-amd64-sap-applications-x\" or \"ibm-sles-15-4-amd64-sap-applications-x\"."
 }
}

variable "HANA_SID" {
	type		= string
	description = "HANA_SID"
	default		= "HDB"
	validation {
		condition     = length(regexall("^[a-zA-Z][a-zA-Z0-9][a-zA-Z0-9]$", var.HANA_SID)) > 0
		error_message = "The HANA_SID is not valid."
	}
}

variable "HANA_SYSNO" {
	type		= string
	description = "HANA_SYSNO"
	default		= "00"
	validation {
		condition     = var.HANA_SYSNO >= 0 && var.HANA_SYSNO <=97
		error_message = "The HANA_SYSNO is not valid."
	}
}

variable "HANA_MAIN_PASSWORD" {
	type		= string
	sensitive = true
	description = "HANA_MAIN_PASSWORD"
	validation {
		condition     = length(regexall("^(.{0,7}|.{15,}|[^0-9a-zA-Z]*)$", var.HANA_MAIN_PASSWORD)) == 0 && length(regexall("^[^0-9_][0-9a-zA-Z!@#$_]+$", var.HANA_MAIN_PASSWORD)) > 0
		error_message = "The HANA_MAIN_PASSWORD is not valid."
	}
}

variable "HANA_SYSTEM_USAGE" {
	type		= string
	description = "HANA_SYSTEM_USAGE"
	default		= "custom"
	validation {
		condition     = contains(["production", "test", "development", "custom" ], var.HANA_SYSTEM_USAGE )
		error_message = "The HANA_SYSTEM_USAGE must be one of: production, test, development, custom."
	}
}

variable "HANA_COMPONENTS" {
	type		= string
	description = "HANA_COMPONENTS"
	default		= "server"
	validation {
		condition     = contains(["all", "client", "es", "ets", "lcapps", "server", "smartda", "streaming", "rdsync", "xs", "studio", "afl", "sca", "sop", "eml", "rme", "rtl", "trp" ], var.HANA_COMPONENTS )
		error_message = "The HANA_COMPONENTS must be one of: all, client, es, ets, lcapps, server, smartda, streaming, rdsync, xs, studio, afl, sca, sop, eml, rme, rtl, trp."
	}
}

variable "KIT_SAPHANA_FILE" {
	type		= string
	description = "KIT_SAPHANA_FILE"
	default		= "/storage/HANADB/51055299.ZIP"
}

variable "SAP_SID" {
	type		= string
	description = "SAP_SID"
	default		= "S4A"
	validation {
		condition     = length(regexall("^[a-zA-Z][a-zA-Z0-9][a-zA-Z0-9]$", var.SAP_SID)) > 0
		error_message = "The SAP_SID is not valid."
	}
}

variable "SAP_ASCS_INSTANCE_NUMBER" {
	type		= string
	description = "SAP_ASCS_INSTANCE_NUMBER"
	default		= "01"
	validation {
		condition     = var.SAP_ASCS_INSTANCE_NUMBER >= 0 && var.SAP_ASCS_INSTANCE_NUMBER <=97
		error_message = "The SAP_ASCS_INSTANCE_NUMBER is not valid."
	}
}

variable "SAP_CI_INSTANCE_NUMBER" {
	type		= string
	description = "SAP_CI_INSTANCE_NUMBER"
	default		= "00"
	validation {
		condition     = var.SAP_CI_INSTANCE_NUMBER >= 0 && var.SAP_CI_INSTANCE_NUMBER <=97
		error_message = "The SAP_CI_INSTANCE_NUMBER is not valid."
	}
}

variable "SAP_MAIN_PASSWORD" {
	type		= string
	sensitive = true
	description = "SAP_MAIN_PASSWORD"
	validation {
		condition     = length(regexall("^(.{0,9}|.{15,}|[^0-9]*)$", var.SAP_MAIN_PASSWORD)) == 0 && length(regexall("^[^0-9_][0-9a-zA-Z@#$_]+$", var.SAP_MAIN_PASSWORD)) > 0
		error_message = "The SAP_MAIN_PASSWORD is not valid."
	}
}

variable "HDB_CONCURRENT_JOBS" {
	type		= string
	description = "HDB_CONCURRENT_JOBS"
	default		= "23"
	validation {
		condition     = var.HDB_CONCURRENT_JOBS >= 1 && var.HDB_CONCURRENT_JOBS <=25
		error_message = "The HDB_CONCURRENT_JOBS is not valid."
	}
}

variable "KIT_SAPCAR_FILE" {
	type		= string
	description = "KIT_SAPCAR_FILE"
	default		= "/storage/BW4HANA/SAPCAR_1010-70006178.EXE"
}

variable "KIT_SWPM_FILE" {
	type		= string
	description = "KIT_SWPM_FILE"
	default		= "/storage/BW4HANA/SWPM20SP09_4-80003424.SAR"
}

variable "KIT_SAPEXE_FILE" {
	type		= string
	description = "KIT_SAPEXE_FILE"
	default		= "/storage/BW4HANA/SAPEXE_400-80004393.SAR"
}

variable "KIT_SAPEXEDB_FILE" {
	type		= string
	description = "KIT_SAPEXEDB_FILE"
	default		= "/storage/BW4HANA/SAPEXEDB_400-80004392.SAR"
}

variable "KIT_IGSEXE_FILE" {
	type		= string
	description = "KIT_IGSEXE_FILE"
	default		= "/storage/BW4HANA/igsexe_13-80003187.sar"
}

variable "KIT_IGSHELPER_FILE" {
	type		= string
	description = "KIT_IGSHELPER_FILE"
	default		= "/storage/BW4HANA/igshelper_17-10010245.sar"
}

variable "KIT_SAPHOSTAGENT_FILE" {
	type		= string
	description = "KIT_SAPHOSTAGENT_FILE"
	default		= "/storage/BW4HANA/SAPHOSTAGENT51_51-20009394.SAR"
}

variable "KIT_HDBCLIENT_FILE" {
	type		= string
	description = "KIT_HDBCLIENT_FILE"
	default		= "/storage/BW4HANA/IMDB_CLIENT20_009_28-80002082.SAR"
}

variable "KIT_BW4HANA_EXPORT" {
	type		= string
	description = "KIT_BW4HANA_EXPORT"
	default		= "/storage/BW4HANA/export"
}
