
output "certificate_arn" {
  value = var.create_cert ? aws_acm_certificate_validation.main[0].certificate_arn : ""
}
