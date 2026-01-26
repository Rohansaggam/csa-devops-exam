terraform {
  backend "s3" {
    bucket = "jenkins-terraform-backend-store"
    key    = "stage1/terraform.tfstate"
    region = "us-east-1"
  }
}
