resource "aws_db_instance" "rds-postgresql" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "postgres"
  engine_version       = "12.4"
  instance_class       = "db.t2.micro"
  name                 = "uscovid19db"
  username             = "foo"
  password             = "foobarbaz"
}