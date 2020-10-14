terraform {
  backend "s3" {
    bucket = "terraformbackendankit11"
    key    = "mytf"
    region = "us-east-1"
  }
}