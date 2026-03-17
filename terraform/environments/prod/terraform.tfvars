
aws_region    = "ap-southeast-2"
project_name  = "myapp"
environment   = "prod"

vpc_cidr        = "10.3.0.0/16"
azs             = ["ap-southeast-2a", "ap-southeast-2b", "ap-southeast-2c"]
public_subnets  = ["10.3.1.0/24", "10.3.2.0/24", "10.3.3.0/24"]
private_subnets = ["10.3.11.0/24", "10.3.12.0/24", "10.3.13.0/24"]

create_route53_record = true
# domain_name    = "myapp.example.com"
# hosted_zone_id = "Z1234567890ABC"

task_cpu      = "2048"
task_memory   = "4096"
desired_count = 2
min_capacity  = 2
max_capacity  = 10
capacity_provider = "FARGATE"

rds_instance_class      = "db.r6g.large"
rds_multi_az            = true
rds_deletion_protection = true

ecr_image_mutability = "IMMUTABLE"
log_retention_days   = 90
