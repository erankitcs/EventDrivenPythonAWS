data "aws_db_subnet_group" "database" {
  name = aws_db_instance.rds-postgresql.db_subnet_group_name
}

data "aws_vpc" "default_vpc" {
  default = true
}

data "aws_route_table" "routetbl" {
  vpc_id  = data.aws_vpc.default_vpc.id
}