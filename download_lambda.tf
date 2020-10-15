####Lambda Function to load files into S3 bucket.
resource "aws_iam_role" "download_lambda_role" {
  name               = "${local.name_prefix}-download_lambda_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

## Attach basic lambda role for cloudwatch
resource "aws_iam_role_policy_attachment" "download_lambda_role_cloudwatch" {
  role       = aws_iam_role.download_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

## Policy for accessing S3 bucket
resource "aws_iam_policy" "lambda_S3_policy_write" {
  name        = "lambda_S3_policy_write"
  path        = "/"
  description = "Policy for accessing S3 Write."
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:PutObject",
        "s3:ListBucket",
        "s3:GetObjectVersion"
      ],
      "Effect": "Allow",
      "Sid": "AllowS3Write",
      "Resource": ["${aws_s3_bucket.covid19bucket.arn}/*", "${aws_s3_bucket.covid19bucket.arn}" ]
    },
	{
            "Sid": "AllowList",
            "Effect": "Allow",
            "Action": "s3:ListAllMyBuckets",
            "Resource": "*"
        }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "s3-write-access-attach" {
  role       = aws_iam_role.download_lambda_role.name
  policy_arn = aws_iam_policy.lambda_S3_policy_write.arn
}

## Giving permission to load into S3
#resource "aws_iam_role_policy_attachment" "download_lambda_role_S3" {
#  role       = aws_iam_role.download_lambda_role.name
#  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
#}


## Policy for publishing to SNS
resource "aws_iam_policy" "download_lambda_SNS_Publish" {
  name        = "download_lambda_SNS_Publish"
  path        = "/"
  description = "Policy for publishing to SNS."
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
            "Sid": "Allowpub",
            "Effect": "Allow",
            "Action": "sns:Publish",
            "Resource": ["${aws_sns_topic.error_topic.arn}","${aws_sns_topic.filesavailable.arn}"]
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "SNS-pub-access-attach_download_lambda" {
  role       = aws_iam_role.download_lambda_role.name
  policy_arn = aws_iam_policy.download_lambda_SNS_Publish.arn
}

## Giving permission to publish into SNS
#resource "aws_iam_role_policy_attachment" "download_lambda_role_SNS" {
#  role       = aws_iam_role.download_lambda_role.name
#  policy_arn = "arn:aws:iam::aws:policy/AmazonSNSFullAccess"
#}


data "archive_file" "download_lambda_package" {
  source_dir  = "${path.module}/lambda_filedownload/"
  output_path = "${path.module}/lambda_filedownload.zip"
  type        = "zip"
  depends_on = [null_resource.lambda_build]
}

## Lambda Function to download files into S3
resource "aws_lambda_function" "download_lambda_fn" {
  function_name    = "${local.name_prefix}-download-lambda"
  handler          = "handler.lambda_handler"
  role             = aws_iam_role.download_lambda_role.arn
  runtime          = var.runtime
  timeout          = 60
  filename         = data.archive_file.download_lambda_package.output_path
  source_code_hash = data.archive_file.download_lambda_package.output_base64sha256
  environment {
    variables = {
      New_York_Times_COVID19_Data_URL = var.nyt_url
      Johns_Hopkins_COVID19_Data_URL = var.jh_url
      BUCKET =  aws_s3_bucket.covid19bucket.id
      TOPIC =  aws_sns_topic.filesavailable.arn
      ERROR_TOPIC = aws_sns_topic.error_topic.arn
    }
  }
}
