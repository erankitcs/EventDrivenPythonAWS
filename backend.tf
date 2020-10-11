terraform {
  backend "s3" {
    bucket = "terraformbackendankit"
    key    = "mytf"
    region = "us-east-1"
  }
}