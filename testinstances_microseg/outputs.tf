# AWS Spoke 1 Test Instances Private IP
output "sp-aw-apne2-01-vpc-test_instances_pvt_ip" {
  value       = { for key, instance in module.aws_testinst_sp-aw-apne2-01-vpc_info.test_instance_info_all : key => [instance["private_ip"], instance.tags.role] }
  description = "Map of private IPs of all instances deployed in sp-aw-apne2-01 VPC"
}

# AWS Spoke 2 Test Instances Private IP
output "sp-aw-aps1-01-vpc-instances_pvt_ip" {
  value       = { for key, instance in module.aws_testinst_sp-aw-aps1-01-vpc.test_instance_info_all : key => [instance["private_ip"], instance.tags.role] }
  description = "Map of private IPs of all instances deployed in sp-aw-aps1-01 VPC"
}

# AWS Spoke 1 Jump host public IP
output "jump_host_sp-aw-aps1-01_pubIP" {
  value       = local.jump_host_sp-aw-aps1-01_pubIP
  description = "Jump host public and private IP"
}

# AWS Spoke 2 Jump host public IP
output "jump_host_sp-aw-apne2-01_pubIP" {
  value       = local.jump_host_sp-aw-apne2-01_pubIP
  description = "Jump host public and private IP"
}


# AZ Spoke 1 & 2 Jump hosts public IP
output "az_vpcs_jmp_hosts_ips" {
  value       = { for key, jmp_host in module.az_linux_jumphost_per_vpc : "${key}_pubip" => [jmp_host.public_ip_address, jmp_host.network_interface_private_ip[0]] }
  description = "AZ Jump host public IP"
}

# AZ Spoke 1 & 2 test_inst Private  IP

output "az_vpcs_test_inst_pvtIP" {
  value = { for key, instance in module.az_linux_test_insts : key => [instance.network_interface_private_ip[0], instance.vm_tags_role[0]] }
}