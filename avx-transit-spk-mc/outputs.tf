output "spk_vpc_names" {
  value       = local.spk_vpc_names
  description = "List of Spoke VPC names deployed in this module"

}

# Details of each spoke VPC deployed 

output "sp-aw-apne2-01-vpc_info" {
  value = local.sp-aw-apne2-01-vpc_info
}

output "sp-aw-aps1-01-vpc_info" {
  #  value = local.sp-aw-aps1-01-vpc_info
  value = {
    "vpc_id"          = module.sp-aw-aps1-01.vpc.vpc_id
    "vpc_name"        = module.sp-aw-aps1-01.vpc.name
    "vpc_region"      = module.sp-aw-aps1-01.vpc.region
    "cloud_type"      = module.sp-aw-aps1-01.vpc.cloud_type
    "pvt_subnet_info" = module.sp-aw-aps1-01.vpc.private_subnets
    "pub_subnet_info" = module.sp-aw-aps1-01.vpc.public_subnets
  }

}

output "sp-az-wus2-01-vpc_info" {
  value = local.sp-az-wus2-01-vpc_info
}

output "sp-az-eus2-01-vpc_info" {
  value = local.sp-az-eus2-01-vpc_info
}