# ─────────────────────────────────────────────────────────────
# ROOT MODULE — wires all modules together
# ─────────────────────────────────────────────────────────────

module "network" {
  source          = "./modules/network"
  project_name    = var.project_name
  environment     = var.environment
  vpc_cidr        = var.vpc_cidr
  azs             = var.azs
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
}

module "security_groups" {
  source       = "./modules/security_groups"
  project_name = var.project_name
  environment  = var.environment
  vpc_id       = module.network.vpc_id
  frontend_port = var.frontend_port
  backend_port  = var.backend_port
}

module "ecr" {
  source              = "./modules/ecr"
  project_name        = var.project_name
  environment         = var.environment
  image_mutability    = var.ecr_image_mutability
}

module "acm" {
  source          = "./modules/acm"
  project_name    = var.project_name
  environment     = var.environment
  domain_name     = var.domain_name
  hosted_zone_id  = var.hosted_zone_id
  create_cert     = var.create_route53_record
}

module "alb" {
  source             = "./modules/alb"
  project_name       = var.project_name
  environment        = var.environment
  vpc_id             = module.network.vpc_id
  public_subnet_ids  = module.network.public_subnet_ids
  alb_sg_id          = module.security_groups.alb_sg_id
  frontend_port      = var.frontend_port
  backend_port       = var.backend_port
  certificate_arn    = module.acm.certificate_arn
  create_https       = var.create_route53_record
}

module "secrets" {
  source       = "./modules/secrets"
  project_name = var.project_name
  environment  = var.environment
}

module "rds" {
  source              = "./modules/rds"
  project_name        = var.project_name
  environment         = var.environment
  private_subnet_ids  = module.network.private_subnet_ids
  rds_sg_id           = module.security_groups.rds_sg_id
  instance_class      = var.rds_instance_class
  multi_az            = var.rds_multi_az
  deletion_protection = var.rds_deletion_protection
  db_password_secret  = module.secrets.db_password_arn
}

module "s3" {
  source       = "./modules/s3"
  project_name = var.project_name
  environment  = var.environment
}

module "ecs" {
  source              = "./modules/ecs"
  project_name        = var.project_name
  environment         = var.environment
  aws_region          = var.aws_region
  private_subnet_ids  = module.network.private_subnet_ids
  ecs_sg_id           = module.security_groups.ecs_sg_id
  frontend_tg_arn     = module.alb.frontend_tg_arn
  backend_tg_arn      = module.alb.backend_tg_arn
  frontend_image      = var.frontend_image != "nginx:latest" ? var.frontend_image : module.ecr.frontend_repository_url
  backend_image       = var.backend_image != "nginx:latest" ? var.backend_image : module.ecr.backend_repository_url
  frontend_port       = var.frontend_port
  backend_port        = var.backend_port
  task_cpu            = var.task_cpu
  task_memory         = var.task_memory
  desired_count       = var.desired_count
  min_capacity        = var.min_capacity
  max_capacity        = var.max_capacity
  capacity_provider   = var.capacity_provider
  db_secret_arn       = module.secrets.db_password_arn
  app_secret_arn      = module.secrets.app_secret_arn
  rds_endpoint        = module.rds.db_endpoint
  s3_bucket_name      = module.s3.bucket_name
  log_retention_days  = var.log_retention_days
}

module "cloudwatch" {
  source          = "./modules/cloudwatch"
  project_name    = var.project_name
  environment     = var.environment
  aws_region      = var.aws_region
  ecs_cluster_name    = module.ecs.cluster_name
  frontend_service    = module.ecs.frontend_service_name
  backend_service     = module.ecs.backend_service_name
  alb_arn_suffix      = module.alb.alb_arn_suffix
  rds_identifier      = module.rds.db_identifier
}

# Optional: Route53 record pointing to ALB
resource "aws_route53_record" "app" {
  count   = var.create_route53_record ? 1 : 0
  zone_id = var.hosted_zone_id
  name    = var.domain_name
  type    = "A"
  alias {
    name                   = module.alb.alb_dns_name
    zone_id                = module.alb.alb_zone_id
    evaluate_target_health = true
  }
}
