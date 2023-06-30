variable "IP" {
    type = string
    description = "IP used to execute ansible"
}

variable "SAP_MAIN_PASSWORD" {
	type		= string
	sensitive = true
	description = "SAP_MAIN_PASSWORD"
}

variable "HANA_MAIN_PASSWORD" {
	type		= string
	sensitive = true
	description = "HANA_MAIN_PASSWORD"
}
