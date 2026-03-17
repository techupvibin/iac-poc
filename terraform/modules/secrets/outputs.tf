
output "db_password_arn" { value = aws_secretsmanager_secret.db_password.arn }
output "app_secret_arn"  { value = aws_secretsmanager_secret.app_secret.arn }
