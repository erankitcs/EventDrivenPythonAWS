terraform {
  backend "s3" {
    bucket = "terraformbackendankit1"
    key    = "mytf"
    region = "us-east-1"
  }
}