output "lambda_etl" {
    value = aws_lambda_function.etl_lambda_fn.arn
    description = "ETL Processing Lambda ARN"
}

output "lambda_file_download" {
    value = aws_lambda_function.download_lambda_fn.arn
    description = "File Download Lambda ARN"
}

output "landing_zone_bucket" {
    value = aws_s3_bucket.covid19bucket.arn
    description = "Landing zone bucket ARN"
}