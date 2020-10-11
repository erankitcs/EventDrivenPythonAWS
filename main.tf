## Creating Lambda Function
resource "aws_iam_role" "lambda_role" {
  name               = "${local.name_prefix}-lambda_role"
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

resource "null_resource" "lambda_build" {
  triggers = {
    rerun_every_time = "${uuid()}"
  }
  provisioner "local-exec" {
    command = "${CODEBUILD_SRC_DIR}/scripts/build_package.sh"
    environment = {
      lambda_source = "${CODEBUILD_SRC_DIR}/newhandler/"
    }
  }
}

data "archive_file" "lambda_with_dependencies" {
  source_dir  = "${CODEBUILD_SRC_DIR}/newhandler/"
  output_path = "${CODEBUILD_SRC_DIR}/handler.zip"
  type        = "zip"
  depends_on = ["null_resource.lambda_build"]
}


resource "aws_lambda_function" "my_lambda_function_with_dependencies" {
  function_name    = "${local.name_prefix}-covid19etl-lambda"
  handler          = "handler.lambda_handler"
  role             = aws_iam_role.lambda_role.arn
  runtime          = var.runtime
  timeout          = 60
  filename         = "handler.zip"
  source_code_hash = filebase64sha256(data.archive_file.lambda_with_dependencies.output_path)
}