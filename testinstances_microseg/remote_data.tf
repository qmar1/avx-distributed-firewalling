data "terraform_remote_state" "vpc_data_01" {

  backend = "s3"

  config = {
    bucket  = "qmar-avx-tf-backed-state-2022"
    key     = "prod-rdy/avx-microseg/avx-transit-spk-mc/terraform.tfstate"
    region  = "us-east-1"
    profile = "kumar"
  }
}

### Data on Azure Linux VM instances

/* data "azurerm_virtual_machine" "linux_test_instances" {

  for_each            = { for key, inst in local.az_test_inst_info : key => inst.host_name }
  name                = "${each.value}-vmlinux-0"
  resource_group_name = azurerm_resource_group.arm_rg.name
} */


# data.terraform_remote_state.vpc_data_01.outputs.sp-aw-apne2-01_vpc_info
# data.terraform_remote_state.vpc_data_01.outputs.sp-aw-aps1-01_vpc_info
# data.terraform_remote_state.vpc_data_01.outputs.sp_az_wus2_01_vpc_info
# data.terraform_remote_state.vpc_data_01.outputs.sp_az_eus2_01_vpc_info


/* Outputs from remote state 
"sp-aw-apne2-01_vpc_info" 

"sp-aw-aps1-01_vpc_info" 

"sp_az_wus2_01_vpc_info" 

"sp_az_eus2_01_vpc_info"
*/