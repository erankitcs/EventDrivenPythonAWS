resource "aws_cloudwatch_event_rule" "every_day_rule" {
    name = "${local.name_prefix}-cw-rule"
    description = "Fires Lambda every day at ${var.trigger_time}"
    schedule_expression = "cron(0 ${var.trigger_time} * * ? *)"
}


resource "aws_cloudwatch_event_target" "download-lambda-target" {
    rule = aws_cloudwatch_event_rule.every_day_rule.name
    target_id = "download_lambda"
    arn = aws_lambda_function.download_lambda_fn.arn
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_download_lambda" {
    statement_id = "AllowExecutionFromCloudWatch"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.download_lambda_fn.function_name
    principal = "events.amazonaws.com"
    source_arn = aws_cloudwatch_event_rule.every_day_rule.arn
}