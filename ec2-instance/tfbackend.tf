terraform {
  backend "s3" {
    bucket = "test-skg-terraform-s3-buck"
    key    = "ec2-instance/terraform.tfstate"
    region = "us-east-2"
  }
}
