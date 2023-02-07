
#---- AWS Transit -----

module "aws_xt_apne2_01" {
  source  = "terraform-aviatrix-modules/mc-transit/aviatrix"
  version = "2.3.0"

  cloud         = "AWS"
  region        = "ap-northeast-2"
  cidr          = "10.101.0.0/16"
  account       = "qmar-aws-primary"
  insane_mode   = false
  instance_size = "t3.medium" #Non-default value required, as minimum instance size for Insane Mode is c5.large

  # Optional parameter

  enable_advertise_transit_cidr = true
  enable_encrypt_volume         = true
  local_as_number               = var.aws_xt_local_as_num
  name                          = "xf-aw-apne2-01"
  gw_name                       = "xf-aw-apne2-01-gw"
  single_az_ha                  = false
  enable_segmentation           = true
  enable_transit_firenet        = false
}

# AWS Firenet 
/* 
module "firenet_pan_01" {
  source  = "terraform-aviatrix-modules/mc-firenet/aviatrix"
  version = "v1.1.1"

  transit_module          = module.aws_xt_apne2_01
  firewall_image          = "Palo Alto Networks VM-Series Next-Generation Firewall (BYOL)"
  fw_amount               = 2
  password                = "Aviatrix#12345"
  iam_role_1              = "bootstrap-VM-S3-role"
  bootstrap_bucket_name_1 = "qmar-pan-bootstrap-bucket"
  # east_west_inspection_excluded_cidrs = []
}
 */
#---- Azure Transit -----

module "az_xt_wus2_01" {
  source  = "terraform-aviatrix-modules/mc-transit/aviatrix"
  version = "2.3.0"

  cloud         = "Azure"
  region        = "West US 2"
  cidr          = "10.121.0.0/16"
  account       = "qmar-az-primary"
  insane_mode   = true
  instance_size = "Standard_D3_v2" #Non-default value required, as minimum instance size for Insane Mode is <>

  # Optional parameter
  az_support                    = true
  enable_advertise_transit_cidr = true
  #enable_encrypt_volume         = false # not supported in AZ/GCP/OCI
  local_as_number        = var.az_xt_local_as_num
  name                   = "az-xt-wus2-01"
  gw_name                = "az-xt-wus2-01-gw"
  single_az_ha           = false
  enable_segmentation    = true
  enable_transit_firenet = false

}

#----- GCP Transit -----

/* module "gcp_xt_euw2_01" {
  source  = "terraform-aviatrix-modules/mc-transit/aviatrix"
  version = "2.1.3"

  cloud         = "GCP"
  region        = "europe-west2"
  cidr          = "10.141.0.0/16"
  account       = "qmar-gcp-primary"
  insane_mode   = true
  instance_size = "n1-highcpu-4" #Non-default value required, as minimum instance size for Insane Mode is c5.large


  # Optional parameter

  enable_advertise_transit_cidr = false # not supported with insane mode on GCP
  enable_encrypt_volume         = false # not supported in AZ/GCP/OCI
  local_as_number               = 65503
  name                          = "xt-gc-euw2-01"
  gw_name                       = "xt-gc-euw2-01-gw"
  single_az_ha                  = false
  enable_segmentation           = true
  enable_transit_firenet        = false
#  lan_cidr                      = "10.142.0.0/16"

} */

# GCP Firenet
/* module "firenet_pan_01" {
  source  = "terraform-aviatrix-modules/mc-firenet/aviatrix"
  version = "v1.1.1"

  transit_module          = module.gcp_xt_euw2_01
  firewall_image          = "Palo Alto Networks VM-Series Next-Generation Firewall BYOL"
  fw_amount               = 2
  password                = "Aviatrix#12345"
  iam_role_1              = "bootstrap-VM-S3-role"
  bootstrap_bucket_name_1 = "qmar-pan-bootstrap-bucket"
  # east_west_inspection_excluded_cidrs = []
  mgmt_cidr   = "10.143.0.0/16"
  egress_cidr = "10.144.0.0/16"
} */


#----- AWS Spoke --------
module "sp-aw-aps1-01" {
  # Mumbai region
  source  = "terraform-aviatrix-modules/mc-spoke/aviatrix"
  version = "1.4.1"

  cloud      = "AWS"
  name       = "sp-aw-aps1-01"
  cidr       = "10.3.0.0/16"
  region     = "ap-south-1"
  account    = "qmar-aws-primary"
  transit_gw = module.aws_xt_apne2_01.transit_gateway.gw_name

  # optional 
  #  network_domain = var.domain_list[length(var.domain_list) - 1] # coreInfra domain
  network_domain = var.domain_list[2] # Prod domain
  single_az_ha   = false
  insane_mode    = false
  instance_size  = "t3.medium"
  single_ip_snat = true # Enable only when using for Micro segmentation or when you need to private subnet instances to have internet access

}

# Insane mode AWS spoke

module "sp-aw-apne2-01" {
  source  = "terraform-aviatrix-modules/mc-spoke/aviatrix"
  version = "1.4.1"

  cloud      = "AWS"
  name       = "sp-aw-apne2-01"
  cidr       = "10.4.0.0/16"
  region     = "ap-northeast-2"
  account    = "qmar-aws-primary"
  transit_gw = module.aws_xt_apne2_01.transit_gateway.gw_name
  #  network_domain = var.domain_list[length(var.domain_list) - 1] # CoreInfra Domain
  network_domain = var.domain_list[2] # prod domain
  # optional 
  #security_domain = ""
  single_az_ha   = false
  insane_mode    = false
  instance_size  = "t3.medium" # Verify if this is supported 
  single_ip_snat = true        # Enable only when using for Micro segmentation or when you need to private subnet instances to have internet access

}

# Azure Spoke with insane mode
module "sp_az_wus2_01" {
  source  = "terraform-aviatrix-modules/mc-spoke/aviatrix"
  version = "1.4.1"

  cloud      = "Azure"
  name       = "sp-az-wus2-01"
  cidr       = "10.21.0.0/16"
  region     = "West US 2"
  account    = "qmar-az-primary"
  transit_gw = module.az_xt_wus2_01.transit_gateway.gw_name
  #network_domain = var.domain_list[length(var.domain_list) - 1] # coreInfra Domain
  network_domain = var.domain_list[2] # prod domain
  single_az_ha   = false
  insane_mode    = false
  #  instance_size  = "Standard_D3_v2"
  az_support     = true
  single_ip_snat = true # Enable only when using for Micro segmentation or when you need to private subnet instances to have internet access

}

# Azure spoke no insance mode 
module "sp_az_eus2_01" {
  source  = "terraform-aviatrix-modules/mc-spoke/aviatrix"
  version = "1.4.1"

  cloud      = "Azure"
  name       = "sp-az-eus2-01"
  cidr       = "10.22.0.0/16"
  region     = "East US 2"
  account    = "qmar-az-primary"
  transit_gw = module.az_xt_wus2_01.transit_gateway.gw_name
  #  network_domain = var.domain_list[length(var.domain_list) - 1] # coreInfra Domain
  network_domain = var.domain_list[2] # prod domain
  single_az_ha   = false
  insane_mode    = false
  #  instance_size  = ""
  az_support     = true
  single_ip_snat = true # Enable only when using for Micro segmentation or when you need to private subnet instances to have internet access

}


#---- GCP Spoke ---------



# Creating Network segmentation Domains 

resource "aviatrix_segmentation_network_domain" "nw_seg_domains" {
  for_each    = toset(var.domain_list)
  domain_name = each.value
}

# Create Transit Peering (Full Mesh)
module "transit-peering" {
  source  = "terraform-aviatrix-modules/mc-transit-peering/aviatrix"
  version = "1.0.8"

  transit_gateways = [
    module.aws_xt_apne2_01.transit_gateway.gw_name,
    module.az_xt_wus2_01.transit_gateway.gw_name
  
  ]
}
