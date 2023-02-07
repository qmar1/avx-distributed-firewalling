data "terraform_remote_state" "vpc_data_01" {

  backend = "s3"

  config = {
    bucket  = "qmar-avx-tf-backed-state-2022"
    key     = "prod-rdy/avx-microseg/avx-transit-spk-mc/terraform.tfstate"
    region  = "us-east-1"
    profile = "kumar"
  }
}
