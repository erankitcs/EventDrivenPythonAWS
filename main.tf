##S3 bucket to store RAW files
resource "aws_s3_bucket" "covid19bucket" {
  bucket   = "covid19ankitlandingzone123"
  acl      = "private"
}

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

## Giving permission to load into S3
resource "aws_iam_role_policy_attachment" "download_lambda_role_S3" {
  role       = aws_iam_role.download_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

## Giving permission to publish into SNS
resource "aws_iam_role_policy_attachment" "download_lambda_role_SNS" {
  role       = aws_iam_role.download_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSNSFullAccess"
}

## Creating SNS Topic

resource "aws_sns_topic" "filesavailable" {
  name = "${local.name_prefix}_filesavailable"
}

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
    }
  }
}

resource "null_resource" "lambda_build" {
  triggers = {
    handler      = "${base64sha256(file("lambda_etl/handler.py"))}"
    requirements = "${base64sha256(file("lambda_etl/requirements.txt"))}"
    build        = "${base64sha256(file("scripts/build_package.sh"))}"
    datatf        = "${base64sha256(file("lambda_etl/modules/datatransform.py"))}"
    db           = "${base64sha256(file("lambda_etl/modules/postgresload.py"))}"
    updateme           = "${base64sha256(file("lambda_etl/updateme.txt"))}"
  }
  provisioner "local-exec" {
    command = "scripts/build_package.sh"
  }
}

data "archive_file" "lambda_package" {
  source_dir  = "${path.module}/lambda_package/"
  output_path = "${path.module}/lambda_etl.zip"
  type        = "zip"
  depends_on = [null_resource.lambda_build]
}

## Creating Lambda Function
resource "aws_iam_role" "lambda_role" {
  name               = "${local.name_prefix}-lambda-role"
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

resource "aws_iam_role_policy_attachment" "vpc-access-attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_role_policy_attachment" "s3-access-attach" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_lambda_permission" "with_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.etl_lambda_fn.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.filesavailable.arn
}

resource "aws_sns_topic_subscription" "etl_lambda_fn_sub" {
  topic_arn = aws_sns_topic.filesavailable.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.etl_lambda_fn.arn
}

resource "aws_vpc_endpoint" "s3_etl_lambda_endpoint" {
  vpc_id       = data.aws_vpc.default_vpc.id
  service_name = "com.amazonaws.${var.aws_region}.s3"
}

resource "aws_vpc_endpoint_route_table_association" "routetable" {
  route_table_id  = data.aws_route_table.routetbl.id
  vpc_endpoint_id = aws_vpc_endpoint.s3_etl_lambda_endpoint.id
}

resource "aws_lambda_function" "etl_lambda_fn" {
  function_name    = "${local.name_prefix}-etl-lambda"
  handler          = "handler.lambda_handler"
  role             = aws_iam_role.lambda_role.arn
  runtime          = var.runtime
  timeout          = 60
  filename         = data.archive_file.lambda_package.output_path
  #source_code_hash = filebase64sha256(data.archive_file.lambda_package.output_path)
  source_code_hash = data.archive_file.lambda_package.output_base64sha256
  vpc_config {
    subnet_ids         = data.aws_db_subnet_group.database.subnet_ids
    security_group_ids = aws_db_instance.rds-postgresql.vpc_security_group_ids
  }
  environment {
    variables = {
      DB_HOST = aws_db_instance.rds-postgresql.address
      DB_PORT = aws_db_instance.rds-postgresql.port
      DB_USER = aws_db_instance.rds-postgresql.username
      DB_PASS = aws_db_instance.rds-postgresql.password
      DB_NAME = aws_db_instance.rds-postgresql.name
      BUCKET =  aws_s3_bucket.covid19bucket.id
      TABLE_NAME = var.table_name
    }
  }
}