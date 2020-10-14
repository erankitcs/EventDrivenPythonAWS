##S3 bucket to store RAW files
resource "aws_s3_bucket" "covid19bucket" {
  bucket   = var.landing_zone_bucket_name
  acl      = "private"
}