data "aws_db_subnet_group" "database" {
  name = aws_db_instance.rds-postgresql.db_subnet_group_name
}

data "aws_vpc" "default_vpc" {
  default = true
}

data "aws_route_table" "routetbl" {
  vpc_id  = data.aws_vpc.default_vpc.id
}

data "aws_secretsmanager_secret" "databse_secret" {
  name = var.databse_secret_name
}

data "aws_secretsmanager_secret_version" "databse_secret_version" {
  secret_id = data.aws_secretsmanager_secret.databse_secret.id
}

### for SNS End point

data "aws_vpc_endpoint_service" "sns" {
  service = "sns"
}
data "aws_vpc_endpoint_service" "secretsmanager" {
  service = "secretsmanager"
}
