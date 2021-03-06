# Three Tier SAP BW/4HANA Stack Deployment using IBM Schematics


## Description
This automation solution is designed for the deployment of **Three Tier SAP BW/4HANA Stack** using IBM Cloud Schematics. The SAP solution will be deployed on top of **Red Hat Enterprise Linux 7.6 for SAP** in an existing IBM Cloud Gen2 VPC, using an existing bastion host with secure remote SSH access.

The solution is based on Terraform remote-exec and Ansible playbooks executed by Schematics and it is implementing a 'reasonable' set of best practices for SAP VSI host configuration.

**It contains:**
- Terraform scripts for the deployment of two VSIs, in an EXISTING VPC, with Subnet and Security Group. The VSIs are intended to be used: one for the data base instance and the other for the application instance.
- Bash scripts used for the checking of the prerequisites required by SAP VSIs deployment and for the integration into a single step in IBM Schematics GUI of the VSI provisioning and the **Three Tier SAP BW/4HANA Stack** installation.
- Ansible scripts to configure Three Tier SAP BW/4HANA primary application server and a HANA 2.0 node.



## Installation media
SAP HANA installation media used for this deployment is the default one for **SAP HANA, platform edition 2.0 SPS05** available at SAP Support Portal under *INSTALLATION AND UPGRADE* area and it has to be provided as input data.

SAP BW/4HANA installation media used for this deployment is the default one for **SAP BW/4HANA 2020** available at SAP Support Portal under *INSTALLATION AND UPGRADE* area and it has to be provided as input data.

## VSI Configuration
The VSIs are deployed with Red Hat Enterprise Linux 7.6 for SAP HANA (amd64) for DB server and Red Hat Enterprise Linux 7.6 for SAP Applications (amd64) for APP server. The SSH keys are configured to allow root user access. The following storage volumes are creating during the provisioning:

HANA DB VSI Disks:
- 3 x 500 GB disks with 10000 IOPS - DATA

SAP APPs VSI Disks:
- 1x 40 GB disk with 10 IOPS / GB - SWAP
- 1 x 128 GB disk with 10 IOPS / GB - DATA

## IBM Cloud API Key
The IBM Cloud API Key should be provided as input value of type sensitive for "ibmcloud_api_key" variable, in `IBM Schematics -> Workspaces -> <Workspace name> -> Settings` menu.
The IBM Cloud API Key can be created [here](https://cloud.ibm.com/iam/apikeys).

## Input parameters
The following parameters can be set in the Schematics workspace: VPC, Subnet, Security group, Resource group, Hostname, Profile, Image, SSH Keys and your SAP system configuration variables, as below:

**VSI input parameters:**

Parameter | Description
----------|------------
ibmcloud_api_key | IBM Cloud API key (Sensitive* value).
private_ssh_key | id_rsa private key content (Sensitive* value).
SSH_KEYS | List of SSH Keys UUIDs that are allowed to SSH as root to the VSI. Can contain one or more IDs. The list of SSH Keys is available [here](https://cloud.ibm.com/vpc-ext/compute/sshKeys). <br /> Sample input (use your own SSH UUIDs from IBM Cloud):<br /> [ "r010-57bfc315-f9e5-46bf-bf61-d87a24a9ce7a" , "r010-3fcd9fe7-d4a7-41ce-8bb3-d96e936b2c7e" ]
BASTION_FLOATING_IP | The FLOATING IP from the Bastion Server.
RESOURCE_GROUP | An EXISTING  Resource Group for VSIs and Volumes resources. <br /> Default value: "Default". The list of Resource Groups is available [here](https://cloud.ibm.com/account/resource-groups).
REGION | The cloud region where to deploy the solution. <br /> The regions and zones for VPC are listed [here](https://cloud.ibm.com/docs/containers?topic=containers-regions-and-zones#zones-vpc). <br /> Review supported locations in IBM Cloud Schematics [here](https://cloud.ibm.com/docs/schematics?topic=schematics-locations).<br /> Sample value: eu-de.
ZONE | The cloud zone where to deploy the solution. <br /> Sample value: eu-de-2.
VPC | EXISTING VPC name. The list of VPCs is available [here](https://cloud.ibm.com/vpc-ext/network/vpcs)
SUBNET | EXISTING Subnet name. The list of Subnets is available [here](https://cloud.ibm.com/vpc-ext/network/subnets). 
SECURITY_GROUP | EXISTING Security group name. The list of Security Groups is available [here](https://cloud.ibm.com/vpc-ext/network/securityGroups). 
DB-HOSTNAME | The Hostname for the HANA VSI. The hostname must have up to 13 characters as required by SAP.  For more information on rules regarding hostnames for SAP systems, check [SAP Note 611361: Hostnames of SAP ABAP Platform servers](https://launchpad.support.sap.com/#/notes/%20611361)
DB-PROFILE |  The instance profile used for the HANA VSI. A list of profiles is available [here](https://cloud.ibm.com/docs/vpc?topic=vpc-profiles) <br>  For more information about supported DB/OS and IBM Gen 2 Virtual Server Instances (VSI), check [SAP Note 2927211: SAP Applications on IBM Virtual Private Cloud](https://launchpad.support.sap.com/#/notes/2927211) <br /> Default value: "mx2-16x128"
DB-IMAGE | The OS image used for HANA VSI. A list of images is available [here](https://cloud.ibm.com/docs/vpc?topic=vpc-about-images).<br /> Default value: ibm-redhat-7-6-amd64-sap-hana-3
APP-HOSTNAME | The Hostname for the SAP Application VSI. The hostname must have up to 13 characters as required by SAP.  For more information on rules regarding hostnames for SAP systems, check [SAP Note 611361: Hostnames of SAP ABAP Platform servers](https://launchpad.support.sap.com/#/notes/%20611361)
APP-PROFILE |  The instance profile used for SAP Application VSI. A list of profiles is available [here](https://cloud.ibm.com/docs/vpc?topic=vpc-profiles) <br>  For more information about supported DB/OS and IBM Gen 2 Virtual Server Instances (VSI), check [SAP Note 2927211: SAP Applications on IBM Virtual Private Cloud](https://launchpad.support.sap.com/#/notes/2927211) <br /> Default value: "bx2-4x16"
APP-IMAGE | The OS image used for SAP Application VSI. A list of images is available [here](https://cloud.ibm.com/docs/vpc?topic=vpc-about-images).<br /> Default value: ibm-redhat-7-6-amd64-sap-applications-3


**SAP input parameters:**

Parameter | Description | Requirements
----------|-------------|-------------
hana_sid | The SAP system ID identifies the SAP HANA system | <ul><li>Consists of exactly three alphanumeric characters</li><li>Has a letter for the first character</li><li>Does not include any of the reserved IDs listed in SAP Note 1979280</li></ul>|
hana_sysno | Specifies the instance number of the SAP HANA system| <ul><li>Two-digit number from 00 to 97</li><li>Must be unique on a host</li></ul>
hana_main_password | Common password for all users that are created during the installation | <ul><li>It must be 8 to 14 characters long</li><li>It must consist of at least one digit (0-9), one lowercase letter (a-z), and one uppercase letter (A-Z).</li><li>It can only contain the following characters: a-z, A-Z, 0-9, !, @, #, $, _</li><li>It must not start with a digit or an underscore ( _ )</li></ul> <br /> (Sensitive* value)
hana_system_usage  | System Usage | Default: custom<br> Valid values: production, test, development, custom
hana_components | SAP HANA Components | Default: server<br> Valid values: all, client, es, ets, lcapps, server, smartda, streaming, rdsync, xs, studio, afl, sca, sop, eml, rme, rtl, trp
kit_saphana_file | Path to SAP HANA ZIP file | As downloaded from SAP Support Portal
sap_sid | The SAP system ID <SAPSID> identifies the entire SAP system | <ul><li>Consists of exactly three alphanumeric characters</li><li>Has a letter for the first character</li><li>Does not include any of the reserved IDs listed in SAP Note 1979280</li></ul>
sap_ascs_instance_number | Technical identifier for internal processes of ASCS| <ul><li>Two-digit number from 00 to 97</li><li>Must be unique on a host</li></ul>
sap_ci_instance_number | Technical identifier for internal processes of CI| <ul><li>Two-digit number from 00 to 97</li><li>Must be unique on a host</li></ul>
sap_main_password | Common password for all users that are created during the installation | <ul><li>It must be 10 to 14 characters long</li><li>It must contain at least one digit (0-9)</li><li>It can only contain the following characters: a-z, A-Z, 0-9, @, #, $, _</li><li>It must not start with a digit or an underscore ( _ )</li></ul> <br /> (Sensitive* value)
hdb_concurrent_jobs | Number of concurrent jobs used to load and/or extract archives to HANA Host | Default: 23
kit_sapcar_file  | Path to sapcar binary | As downloaded from SAP Support Portal
kit_swpm_file | Path to SWPM archive (SAR) | As downloaded from SAP Support Portal
kit_sapexe_file | Path to SAP Kernel OS archive (SAR) | As downloaded from SAP Support Portal
kit_sapexedb_file | Path to SAP Kernel DB archive (SAR) | As downloaded from SAP Support Portal
kit_igsexe_file | Path to IGS archive (SAR) | As downloaded from SAP Support Portal
kit_igshelper_file | Path to IGS Helper archive (SAR) | As downloaded from SAP Support Portal
kit_saphostagent_file | Path to SAP Host Agent archive (SAR) | As downloaded from SAP Support Portal
kit_hdbclient_file | Path to HANA DB client archive (SAR) | As downloaded from SAP Support Portal
kit_bw4hana_export | Path to BW/4HANA Installation Export dir | The archives downloaded from SAP Support Portal should be present in this path

**Obs***: <br />
- Sensitive - The variable value is not displayed in your Schematics logs and it is hidden in the input field.<br />
- The following parameters should have the same values as the ones set for the BASTION server: REGION, ZONE, VPC, SUBNET, SECURITY_GROUP.
- For any manual change in the terraform code, you have to make sure that you use a certified image based on the SAP NOTE: 2927211.


## VPC Configuration

The Security Rules inherited from BASTION deployment are the following:
- Allow all traffic in the Security group for private networks.
- Allow outbound traffic  (ALL for port 53, TCP for ports 80, 443, 8443)
- Allow inbound SSH traffic (TCP for port 22) from IBM Schematics Servers.


 ## Files description and structure:

 - `modules` - directory containing the terraform modules
 - `main.tf` - contains the configuration of the VSI for the deployment of the current SAP solution.
 - `output.tf` - contains the code for the information to be displayed after the VSI is created (Hostname, Private IP)
 - `integration*.tf` - contains the integration code that makes the SAP variabiles from Terraform available to Ansible.
 - `provider.tf` - contains the IBM Cloud Provider data in order to run `terraform init` command.
 - `terraform.tfvars` - contains the IBM Cloud API key referenced in `provider.tf` (dynamically generated)
 - `variables.tf` - contains variables for the VPC and VSI
 - `versions.tf` - contains the minimum required versions for terraform and IBM Cloud provider.


## Steps to reproduce:

1.  Be sure that you have the??[required IBM Cloud IAM
    permissions](https://cloud.ibm.com/docs/vpc?topic=vpc-managing-user-permissions-for-vpc-resources)??to
    create and work with VPC infrastructure and you are??[assigned the
    correct
    permissions](https://cloud.ibm.com/docs/schematics?topic=schematics-access)??to
    create the workspace in Schematics and deploy resources.
2.  [Generate an SSH
    key](https://cloud.ibm.com/docs/vpc?topic=vpc-ssh-keys).
    The SSH key is required to access the provisioned VPC virtual server
    instances via the bastion host. After you have created your SSH key,
    make sure to??[upload this SSH key to your IBM Cloud
    account](https://cloud.ibm.com/docs/vpc-on-classic-vsi?topic=vpc-on-classic-vsi-managing-ssh-keys#managing-ssh-keys-with-ibm-cloud-console)??in
    the VPC region and resource group where you want to deploy the SAP solution
3.  Create the Schematics workspace:
    1.  From the IBM Cloud menu
    select??[Schematics](https://cloud.ibm.com/schematics/overview).
       - Click??Create a workspace.   
       - Enter a name for your workspace.   
       - Click??Create??to create your workspace.
    2.  On the workspace??**Settings**??page, enter the URL of this solution in the Schematics examples Github repository.
     - Select the latest Terraform version.
     - Click??**Save template information**.
     - In the??**Input variables**??section, review the default input variables and provide alternatives if desired.
    - Click??**Save changes**.

4.  From the workspace??**Settings**??page, click??**Generate plan**??
5.  Click??**View log**??to review the log files of your Terraform
    execution plan.
6.  Apply your Terraform template by clicking??**Apply plan**.
7.  Review the log file to ensure that no errors occurred during the
    provisioning, modification, or deletion process.

The output of the Schematics Apply Plan will list the public/private IP addresses
of the VSI host, the hostname and the VPC.  


### Related links:

- [How to create a BASTION/STORAGE VSI for SAP in IBM Schematics](https://github.com/IBM-Cloud/sap-bastion-setup)
- [Securely Access Remote Instances with a Bastion Host](https://www.ibm.com/cloud/blog/tutorial-securely-access-remote-instances-with-a-bastion-host)
- [VPNs for VPC overview: Site-to-site gateways and Client-to-site servers.](https://cloud.ibm.com/docs/vpc?topic=vpc-vpn-overview)
- [IBM Cloud Schematics](https://www.ibm.com/cloud/schematics)
