### Variables 

variable "usr_tag" {
  description = "Name for a user to prepend in tags"
  type        = string

}

variable "ec2_instance_type" {

  description = "type of instance"
  type        = string
  default     = "t2.micro"

}

variable "iperf_port" {
  description = "iperf port to allow communications"
  type        = number
  default     = 5201
  validation {
    condition = (var.iperf_port > 1024 &&
      var.iperf_port < 65536
    )
    error_message = "Please choose a port > 1024 and < 65000."
  }
}

variable "aws_key_name" {
  description = "ec2 key name to use"
  type        = string
}

/* variable "aws_instance_name" {
  description = "Name for the test instance, will be suffixed with number"
  type        = string
}  */

variable "num_insts_per_subnet" {
  type        = number
  default     = 1
  description = "Number of test instances to be deployed per subnet"
}

# ---- Azure variables --------#
# -----------------------------#

variable "az_rg_name" {
  description = "Azure resource group name"
  type        = string
}

variable "az_rg_region" {
  description = "Region where rg will be deployed"
  type        = string
  default     = "East US 2"
}

variable "az_vm_admin_user" {
  description = "admin user name for azure test and jump host vm"
  type        = string
  default     = "ubuntu"

}

variable "az_vm_ssh_pubkey" {
  description = "Public key location on local system for VM access"
  type        = string
  default     = "~/.ssh/id_rsa.pub"
}

variable "az_jump_host_vm_size" {
  description = "Jump host VM size - same for all VPC jump hosts"
  type        = string
  default     = "Standard_B1s"

}

variable "az_test_inst_vm_size" {
  description = "Test instance VM size - same for all VPC jump hosts"
  type        = string
  default     = "Standard_B1s"

}

variable "az_jmp_hst_vm_os" {
  type        = string
  description = "OS to be deployed,  eg: ubuntu 20 "
  default     = "value"
}

variable "az_vm_jmp_hst_hostname" {
  description = "Host name of jump host"
  type        = string
}

variable "nb_inst_per_subnet" {
  description = "Number of Instances to be deployed per pvt instance"
  type        = number
  default     = 1
}

## Locals 

locals {

  # Source for the ami_id : https://cloud-images.ubuntu.com/locator/ec2/
  ubuntu_20_amis = {
    "af-south-1"     = "ami-086ba5619d5ca0a2d",
    "ap-east-1"      = "ami-06197a57d460aaaec",
    "ap-northeast-1" = "ami-079c663c50413a220",
    "ap-south-1"     = "ami-0afe0ab87c09ab68a",
    "ap-southeast-1" = "ami-0d3b2e26119a851ac",
    "ca-central-1"   = "ami-0a8f1768d392eee9b",
    "eu-central-1"   = "ami-0ce4b8a18a8605eff",
    "eu-north-1"     = "ami-0bc337ab82f7c00b4",
    "eu-south-1"     = "ami-0012ad81fe6f58285",
    "eu-west-1"      = "ami-0f2146ee4fa7ba1d1",
    "me-south-1"     = "ami-00c212766accdc8b2",
    "sa-east-1"      = "ami-0a7339745736ef59b",
    "us-east-1"      = "ami-09cce346b3952cce3",
    "us-west-1"      = "ami-008c4a1500b5ebb25",
    "cn-north-1"     = "ami-0741e7b8b4fb0001c",
    "cn-northwest-1" = "ami-0883e8062ff31f727",
    "us-gov-east-1"  = "ami-0eb7ef4cc0594fa04",
    "us-gov-west-1"  = "ami-029a634618d6c0300",
    "ap-northeast-2" = "ami-048299d2b7b438e05",
    "ap-southeast-2" = "ami-0ab20ab938102813f",
    "eu-west-2"      = "ami-0493e28e0af3e55b5",
    "us-east-2"      = "ami-02551addc1e50c0a4",
    "us-west-2"      = "ami-078c065e38be7296e",
    "ap-northeast-3" = "ami-0031d931a171fea9a",
    "ap-southeast-3" = "ami-066158dab514dfe62",
    "eu-west-3"      = "ami-04b985fe4df4c1ccb"
  }

  # Values for generating output jump-host-sp-aw-aps1-01-vpc

  jump_host_sp-aw-aps1-01_pubIP = flatten([
    for idx, instance in module.jump-host-sp-aw-aps1-01-vpc.test_instance_info_all : {
      public_ip  = instance["public_ip"]
      private_ip = instance["private_ip"]
    }
  ])

  jump_host_sp-aw-apne2-01_pubIP = flatten([
    for idx, instance in module.jump-host-sp-aw-apne2-01-vpc.test_instance_info_all : {
      public_ip  = instance["public_ip"]
      private_ip = instance["private_ip"]
    }
  ])

  remote_data = data.terraform_remote_state.vpc_data_01.outputs


  # AZ related Local Values

  # Get all VPC names

  # Get list of AZ VPC names
  # check for sp_az in list of VPC names from the output
  az_spk_pattrn   = "sp-az"
  all_az_spk_keys = [for spk in keys(local.remote_data) : "${spk}" if length(regexall(local.az_spk_pattrn, spk)) > 0]

  # Get list of AWS VPC names 
  aws_spk_pattrn   = "sp-aw"
  all_aws_spk_keys = [for spk in keys(local.remote_data) : "${spk}" if length(regexall(local.aws_spk_pattrn, spk)) > 0]

  # Build a map of VPC and corresponding public Subnet ID to deploy jump host

  az_jump_hosts_info = [
    for vpc in local.all_az_spk_keys : {
      pub_sub_id    = local.remote_data[vpc].pub_subnet_info[1].subnet_id
      jmp_host_name = "${var.az_vm_jmp_hst_hostname}-${local.remote_data[vpc].vpc_name}"
      region        = local.remote_data[vpc].vpc_region
    }
  ]
  # Build map of private subnet ids , instance names and regions for deploying test instances 

  az_test_inst_info = flatten([
    for i, vpc in local.all_az_spk_keys : [
      for indx, pvt_subnet in local.remote_data[vpc].pvt_subnet_info : {
        pvt_sub_id = pvt_subnet.subnet_id
        host_name  = "test-inst-${local.remote_data[vpc].vpc_name}-${indx}"
        region     = local.remote_data[vpc].vpc_region
        # Alternating even VPC instances to prod and odd VPC instances to dev
        role = i % 2 == 0 ? "prod" : "dev"

      }
    ]
  ])

  # NGS to create 

  az_nsg_allow_all_info = [
    for i, vpc in local.all_az_spk_keys : {
      nsg_name = "nsg-allow-all-${local.remote_data[vpc].vpc_name}"
      region   = local.remote_data[vpc].vpc_region
    }
  ]

  az_nsg_names = [
    for i, inst in module.az_linux_test_insts : {
      nsg_name = inst.network_security_group_name
    }
  ]

}



