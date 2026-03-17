
resource "random_password" "db_password" {
  length  = 24
  special = false
}

resource "random_password" "app_secret" {
  length  = 32
  special = false
}

resource "aws_secretsmanager_secret" "db_password" {
  name                    = "${var.project_name}/${var.environment}/db_password"
  recovery_window_in_days = 0  # Allow immediate deletion in POC
  tags = { Name = "${var.project_name}-${var.environment}-db-password" }
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = random_password.db_password.result
}

resource "aws_secretsmanager_secret" "app_secret" {
  name                    = "${var.project_name}/${var.environment}/app_secret"
  recovery_window_in_days = 0
  tags = { Name = "${var.project_name}-${var.environment}-app-secret" }
}

resource "aws_secretsmanager_secret_version" "app_secret" {
  secret_id     = aws_secretsmanager_secret.app_secret.id
  secret_string = random_password.app_secret.result
}
