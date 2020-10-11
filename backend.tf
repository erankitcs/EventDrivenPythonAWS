terraform {
  backend "s3" {
    bucket = "terraformbackendankit"
    key    = "mytf.tfstate"
    region = "us-east-1"
  }
}