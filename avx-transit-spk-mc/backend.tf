terraform {
  backend "s3" {
    # Replace this with your bucket name!
    bucket  = "qmar-avx-tf-backed-state-2022"
    key     = "prod-rdy/avx-transit-spk-mc/terraform.tfstate"
    region  = "us-east-1"
    profile = "kumar"

    # Replace this with your DynamoDB table name!
    dynamodb_table = "qmar-avx-tf-backed-state-locks"
    encrypt        = true

  }
}

