variable "controller_ip" {
  type = string

}

variable "ctrl_user_name" {

  type = string
}

variable "ctrl_psswd" {
  type = string
}

variable "aws_xt_local_as_num" {
  default     = 65500
  type        = string
  description = "local as number for AWS xt"
}

variable "az_xt_local_as_num" {
  default     = 65501
  type        = string
  description = "local as number for az xt"
}

variable "gcp_xt_local_as_num" {
  default     = 65002
  type        = string
  description = "local as number for gcp xt"
}

variable "oci_xt_local_as_num" {
  default     = 65003
  type        = string
  description = "local as number for oci xt"
}

variable "aws_sp_local_as_num" {
  default     = 65010
  type        = string
  description = "local as number for AWS spoke"
}

# List of domain names
variable "domain_list" {

  default     = ["datacenters2c", "customers2c", "prod", "dev", "isolated", "coreInfra"]
  type        = list(any)
  description = "List of domain names to create. coreInfra should be the last in the list"
}

locals {
  spk_vpc_names = ["sp-aw-apne2-01", "sp-aw-aps1-01", "sp-az-wus2-01", "sp-az-eus2-01"]

  sp-aw-apne2-01-vpc_info = {
    "pvt_subnet_info" = module.sp-aw-apne2-01.vpc.private_subnets
    "pub_subnet_info" = module.sp-aw-apne2-01.vpc.public_subnets
    "vpc_name"        = module.sp-aw-apne2-01.vpc.name
    "vpc_region"      = module.sp-aw-apne2-01.vpc.region
    "vpc_id"          = module.sp-aw-apne2-01.vpc.vpc_id
    "cloud_type"      = module.sp-aw-apne2-01.vpc.cloud_type
  }

    sp-az-wus2-01-vpc_info = {
    "vpc_id"          = module.sp_az_wus2_01.vpc.vpc_id
    "vpc_name"        = module.sp_az_wus2_01.vpc.name
    "vpc_region"      = module.sp_az_wus2_01.vpc.region
    "cloud_type"      = module.sp_az_wus2_01.vpc.cloud_type
    "pvt_subnet_info" = module.sp_az_wus2_01.vpc.private_subnets
    "pub_subnet_info" = module.sp_az_wus2_01.vpc.public_subnets
  }

  sp-az-eus2-01-vpc_info = {
    "vpc_id"          = module.sp_az_eus2_01.vpc.vpc_id
    "vpc_name"        = module.sp_az_eus2_01.vpc.name
    "vpc_region"      = module.sp_az_eus2_01.vpc.region
    "cloud_type"      = module.sp_az_eus2_01.vpc.cloud_type
    "pvt_subnet_info" = module.sp_az_eus2_01.vpc.private_subnets
    "pub_subnet_info" = module.sp_az_eus2_01.vpc.public_subnets
  }

}

