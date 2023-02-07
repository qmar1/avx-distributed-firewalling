terraform {
  required_providers {
    aviatrix = {
      source  = "AviatrixSystems/aviatrix"
      version = "3.0.0"

    }
  }
}

provider "aviatrix" {
  controller_ip           = var.controller_ip
  username                = var.ctrl_user_name
  password                = var.ctrl_psswd
  skip_version_validation = true

}