output "spk_vpc_names" {
  value       = local.spk_vpc_names
  description = "List of Spoke VPC names deployed in this module"

}

# Details of each spoke VPC deployed 

output "sp-aw-apne2-01-vpc_info" {
  value = local.sp-aw-apne2-01-vpc_info
}

output "sp-aw-aps1-01-vpc_info" {
  value = local.sp-aw-aps1-01-vpc_info
}

output "sp-az-wus2-01-vpc_info" {
  value = local.sp-az-wus2-01-vpc_info
}

output "sp-az-eus2-01-vpc_info" {
  value = local.sp-az-eus2-01-vpc_info
}