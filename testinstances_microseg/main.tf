# AWS Test Instances
# AWS Private subnet resources 
# Instances in Prod VPC 

module "aws_testinst_sp-aw-apne2-01-vpc_info" {

  source = "github.com/qmar1/terraform-modules.git//aws-testinstances"
  #  source = "../../../modules/aws-testinstances"
  providers = {
    aws = aws.ap-northeast-2 # Needs to change if deploying VPC in a different region
  }
  num_insts_per_subnet = var.num_insts_per_subnet
  ami_id               = local.ubuntu_20_amis["${data.terraform_remote_state.vpc_data_01.outputs.sp-aw-apne2-01-vpc_info["vpc_region"]}"]
  ec2_instance_type    = var.ec2_instance_type
  subnet_ids           = data.terraform_remote_state.vpc_data_01.outputs.sp-aw-apne2-01-vpc_info.pvt_subnet_info[*].subnet_id # List of subnets 
  need_public_ip       = false                                                                                                # Set to false for deploying in private subnet
  key_name             = var.aws_key_name
  secgrp_vpc_id        = data.terraform_remote_state.vpc_data_01.outputs.sp-aw-apne2-01-vpc_info["vpc_id"]
  #  instance_name = var.aws_instance_name
  custom_tags = {
    "created_by"    = "${var.usr_tag}_tf"
    "to_destroy"    = "true"
    "env"           = "microseg_avx"
    "role"          = "prod"
    "public_access" = "false"
    "Name"          = "test-inst-${data.terraform_remote_state.vpc_data_01.outputs.sp-aw-apne2-01-vpc_info["vpc_id"]}"
  }

}

# AWS private subnet resources 
# Instances in Dev VPC for web_app instances

module "aws_testinst_sp-aw-aps1-01-vpc" {

  source = "github.com/qmar1/terraform-modules.git//aws-testinstances"
  #  source = "../../../modules/aws-testinstances"

  providers = {
    aws = aws.ap-south-1 # Needs to change if deploying VPC in a different region
  }
  num_insts_per_subnet = var.num_insts_per_subnet
  ami_id               = local.ubuntu_20_amis["${data.terraform_remote_state.vpc_data_01.outputs.sp-aw-aps1-01-vpc_info["vpc_region"]}"]
  ec2_instance_type    = var.ec2_instance_type
  subnet_ids           = data.terraform_remote_state.vpc_data_01.outputs.sp-aw-aps1-01-vpc_info.pvt_subnet_info[*].subnet_id # List of subnets 
  need_public_ip       = false                                                                                               # Set to false for deploying in private subnet
  key_name             = var.aws_key_name
  secgrp_vpc_id        = data.terraform_remote_state.vpc_data_01.outputs.sp-aw-aps1-01-vpc_info["vpc_id"]
  custom_tags = {
    "created_by"    = "qmar_tf"
    "to_destroy"    = "true"
    "env"           = "microseg_avx"
    "role"          = "dev"
    "public_access" = "false"
    "Name"          = "test-inst-${data.terraform_remote_state.vpc_data_01.outputs.sp-aw-aps1-01-vpc_info["vpc_id"]}"
  }
}

# Jump host instance in the prod sp-aw-aps1-01 VPC to access all resources
# Jump host instance should have SG access to all instances in the private subnet.
# One Jump host per VPC
module "jump-host-sp-aw-aps1-01-vpc" {

  source = "github.com/qmar1/terraform-modules.git//aws-testinstances"
  #  source = "../../../modules/aws-testinstances"
  providers = {
    aws = aws.ap-south-1 # Needs to change if deploying VPC in a different region
  }
  num_insts_per_subnet = 1
  ami_id               = local.ubuntu_20_amis["${data.terraform_remote_state.vpc_data_01.outputs.sp-aw-aps1-01-vpc_info["vpc_region"]}"]
  ec2_instance_type    = var.ec2_instance_type
  subnet_ids           = tolist([data.terraform_remote_state.vpc_data_01.outputs.sp-aw-aps1-01-vpc_info["pub_subnet_info"][0]["subnet_id"]]) # List of subnets 
  need_public_ip       = true                                                                                                                # Set to false for deploying in private subnet
  key_name             = var.aws_key_name
  security_group_name  = "jump_host_sg"
  secgrp_vpc_id        = data.terraform_remote_state.vpc_data_01.outputs.sp-aw-aps1-01-vpc_info["vpc_id"]
  #  instance_name = var.aws_instance_name
  custom_tags = {
    "created_by"    = "qmar_tf"
    "to_destroy"    = "true"
    "env"           = "microseg_avx"
    "role"          = "jump_host"
    "public_access" = "true"
    "Name"          = "jmp_host_sp-aw-aps1-01"
  }

}

module "jump-host-sp-aw-apne2-01-vpc" {

  source = "github.com/qmar1/terraform-modules.git//aws-testinstances"
  #  source = "../../../modules/aws-testinstances"
  providers = {
    aws = aws.ap-northeast-2 # Needs to change if deploying VPC in a different region
  }
  num_insts_per_subnet = 1
  ami_id               = local.ubuntu_20_amis["${data.terraform_remote_state.vpc_data_01.outputs.sp-aw-apne2-01-vpc_info["vpc_region"]}"]
  ec2_instance_type    = var.ec2_instance_type
  subnet_ids           = tolist([data.terraform_remote_state.vpc_data_01.outputs.sp-aw-apne2-01-vpc_info["pub_subnet_info"][0]["subnet_id"]]) # List of subnets 
  need_public_ip       = true                                                                                                                 # Set to false for deploying in private subnet
  key_name             = var.aws_key_name
  security_group_name  = "jump_host_sg"
  secgrp_vpc_id        = data.terraform_remote_state.vpc_data_01.outputs.sp-aw-apne2-01-vpc_info["vpc_id"]
  #  instance_name = var.aws_instance_name
  custom_tags = {
    "created_by"    = "qmar_tf"
    "to_destroy"    = "true"
    "env"           = "microseg_avx"
    "role"          = "jump_host"
    "public_access" = "true"
    "Name"          = "jmp_host_sp-aw-apne2-01"
  }
}

# Azure Test Instances 
# Azure private subnet resources

# RG to deploy all instances in azure for microsegmentation
resource "azurerm_resource_group" "arm_rg" {
  name     = var.az_rg_name
  location = var.az_rg_region
}

# Deploy test ubuntu linux instances in Azure 
module "az_linux_test_insts" {

  for_each = {
    for indx, subnet in local.az_test_inst_info : "test-inst-${subnet.region}-${indx}" => subnet
  }
  source = "github.com/qmar1/terraform-modules.git//az-testinstances"
  #  source              = "../../../modules/az-testinstances/"
  resource_group_name = azurerm_resource_group.arm_rg.name
  vnet_subnet_id      = each.value.pvt_sub_id

  nb_data_disk = 0
  #  data_disk_size_gb = 20
  admin_username                   = var.az_vm_admin_user
  delete_data_disks_on_termination = true
  delete_os_disk_on_termination    = true
  storage_account_type             = "Standard_LRS"
  enable_ssh_key                   = true
  ssh_key                          = var.az_vm_ssh_pubkey
  tags = {

    "created_by"    = "qmar_tf"
    "to_destroy"    = "true"
    "env"           = "microseg_avx"
    "role"          = each.value.role
    "public_access" = "true"
  }
  vm_os_simple = var.az_jmp_hst_vm_os
  vm_hostname  = each.value.host_name
  vm_size      = var.az_test_inst_vm_size
  nb_public_ip = 0
  #remote_port  = "22"
  nb_instances = var.nb_inst_per_subnet
  location     = each.value.region

  # Passing User Data 
  custom_data = file("user-data.sh")

  depends_on = [azurerm_resource_group.arm_rg]

}

## Security Groups to allow all traffic from 0/0 source into the test VM instances
## Test VMs are in private subnets 
## One NSG per VPC. All instances in the VPC will have the same NSG applied

resource "azurerm_network_security_rule" "allow_all_in" {
  for_each                    = { for index, nsg in local.az_nsg_names : index => nsg }
  name                        = "allow_all_in"
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  description                 = "allow_all_in"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.arm_rg.name
  network_security_group_name = each.value.nsg_name
}

resource "azurerm_network_security_rule" "allow_all_out" {
  for_each                    = { for index, nsg in local.az_nsg_names : index => nsg }
  name                        = "allow_all_out"
  priority                    = 101
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  description                 = "allow_all_out"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.arm_rg.name
  network_security_group_name = each.value.nsg_name

}


# Deploy public instance jump host ubuntu linux instances in Azure VPC 
# Will be deployed in the first subnet instance 

module "az_linux_jumphost_per_vpc" {

  for_each = {
    for indx, jmp_host in local.az_jump_hosts_info : "jmp_host_${indx}" => jmp_host
  }
  source                           = "Azure/compute/azurerm"
  version                          = "3.14.0"
  resource_group_name              = azurerm_resource_group.arm_rg.name
  vnet_subnet_id                   = each.value.pub_sub_id
  location                         = each.value.region
  nb_data_disk                     = 0
  admin_username                   = var.az_vm_admin_user
  delete_data_disks_on_termination = true
  delete_os_disk_on_termination    = true
  data_disk_size_gb                = 20
  storage_account_type             = "Standard_LRS"
  enable_ssh_key                   = true
  ssh_key                          = var.az_vm_ssh_pubkey
  tags = {

    "created_by"    = "qmar_tf"
    "to_destroy"    = "true"
    "env"           = "microseg_avx"
    "role"          = "jump_host"
    "public_access" = "true"
  }
  vm_os_simple = var.az_jmp_hst_vm_os
  vm_hostname  = each.value.jmp_host_name
  vm_size      = var.az_jump_host_vm_size
  nb_public_ip = 1
  remote_port  = "22"

  depends_on = [azurerm_resource_group.arm_rg]
}


