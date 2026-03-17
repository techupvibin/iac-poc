output "alb_dns_name" {
  description = "Load balancer DNS — open this in browser to see the app"
  value       = module.alb.alb_dns_name
}
output "ecr_frontend_url" {
  description = "ECR URL for frontend image"
  value       = module.ecr.frontend_repository_url
}
output "ecr_backend_url" {
  description = "ECR URL for backend image"
  value       = module.ecr.backend_repository_url
}
output "rds_endpoint" {
  description = "RDS PostgreSQL endpoint"
  value       = module.rds.db_endpoint
  sensitive   = true
}
output "cloudwatch_dashboard" {
  description = "CloudWatch dashboard URL"
  value       = "https://${var.aws_region}.console.aws.amazon.com/cloudwatch/home#dashboards:name=${var.project_name}-${var.environment}"
}
output "vpc_id" {
  value = module.network.vpc_id
}
