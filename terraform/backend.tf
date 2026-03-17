# Update bucket name after running Step 2 in README
terraform {
  backend "s3" {
    bucket         = "my-terraform-state-poc"
    key            = "sandbox/terraform.tfstate"
    region         = "ap-southeast-2"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}
