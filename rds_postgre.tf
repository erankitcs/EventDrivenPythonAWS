### Creating database withing default VPC
resource "aws_db_instance" "rds-postgresql" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "postgres"
  engine_version       = "12.4"
  instance_class       = "db.t2.micro"
  skip_final_snapshot  = true
  name                 = var.database_name
  username             = jsondecode(data.aws_secretsmanager_secret_version.databse_secret_version.secret_string)["username"]
  password             = jsondecode(data.aws_secretsmanager_secret_version.databse_secret_version.secret_string)["password"]
}