## Creating SNS Topic
resource "aws_sns_topic" "filesavailable" {
  name = "${local.name_prefix}_filesavailable"
}

## Creating Error SNS Topic
resource "aws_sns_topic" "error_topic" {
  name = "${local.name_prefix}_errors"
  provisioner "local-exec" {
    command = "sh scripts/sns_subscription.sh"
    environment = {
      sns_arn = self.arn
      sns_emails = var.technology_subscription_email_address_list
      region     = var.aws_region
    }
  }
}

## Creating Business User SNS Topic to notify when latest data is available.
resource "aws_sns_topic" "business_user_topic" {
  name = "${local.name_prefix}_business_user_success"
  provisioner "local-exec" {
    command = "sh scripts/sns_subscription.sh"
    environment = {
      sns_arn = self.arn
      sns_emails = var.business_subscription_email_address_list
      region     = var.aws_region
    }
  }
}