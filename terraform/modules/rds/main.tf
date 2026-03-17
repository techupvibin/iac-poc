
resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-${var.environment}-db-subnet"
  subnet_ids = var.private_subnet_ids
  tags = { Name = "${var.project_name}-${var.environment}-db-subnet" }
}

data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = var.db_password_secret
}

resource "aws_db_instance" "main" {
  identifier        = "${var.project_name}-${var.environment}-db"
  engine            = "postgres"
  engine_version    = "16.2"
  instance_class    = var.instance_class
  allocated_storage = 20
  storage_type      = "gp3"
  storage_encrypted = true

  db_name  = replace("${var.project_name}${var.environment}", "-", "_")
  username = "dbadmin"
  password = data.aws_secretsmanager_secret_version.db_password.secret_string

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.rds_sg_id]
  multi_az               = var.multi_az
  deletion_protection    = var.deletion_protection
  skip_final_snapshot    = true  # POC — change to false for production
  backup_retention_period = 1

  tags = { Name = "${var.project_name}-${var.environment}-db" }
}
