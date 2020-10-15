terraform {
  backend "s3" {
    bucket = "terraformbackendankit145"
    key    = "mytf"
    region = "us-east-1"
  }
}