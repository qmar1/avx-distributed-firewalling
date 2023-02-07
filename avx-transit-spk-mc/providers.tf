terraform {
  required_providers {
    aviatrix = {
      source  = "aviatrixsystems/aviatrix"
      version = "2.24.0"
    }
    aws = {
      source = "hashicorp/aws"
    }
  }

}

provider "aviatrix" {
  controller_ip           = var.controller_ip
  username                = var.ctrl_user_name
  password                = var.ctrl_psswd
  skip_version_validation = true

}
