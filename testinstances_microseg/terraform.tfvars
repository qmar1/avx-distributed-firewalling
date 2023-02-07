# --- common -----
usr_tag = "qmar"

# --- AWS related test instances variables ---#
# --------------------------------------------#

aws_key_name = "qmar-personal-mbp-key"
#instance_name = "test_instance"
#aws_instance_name = "aws_prod_db_inst"
ec2_instance_type    = "t3.small"
num_insts_per_subnet = 1


# --- Azure related test instances variables ---#
# ----------------------------------------------# 

az_rg_name             = "qmar-arm-rg-mseg-avx"
az_rg_region           = "West US 2"
az_vm_admin_user       = "ubuntu"
az_vm_ssh_pubkey       = "~/.ssh/id_rsa.pub"
az_jmp_hst_vm_os       = "UbuntuServer"
az_vm_jmp_hst_hostname = "jmp-host"

# To get list of supported vm sizes in a region/location
# az vm list-sizes -l eastus2 -o table

az_jump_host_vm_size = "Standard_B1s"
az_test_inst_vm_size = "Standard_B1s"
nb_inst_per_subnet   = 1


