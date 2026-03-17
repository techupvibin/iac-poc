
aws_region    = "ap-southeast-2"
project_name  = "myapp"
environment   = "dev"

vpc_cidr        = "10.1.0.0/16"
azs             = ["ap-southeast-2a", "ap-southeast-2b"]
public_subnets  = ["10.1.1.0/24", "10.1.2.0/24"]
private_subnets = ["10.1.11.0/24", "10.1.12.0/24"]

create_route53_record = false

task_cpu      = "512"
task_memory   = "1024"
desired_count = 1
min_capacity  = 1
max_capacity  = 3
capacity_provider = "FARGATE_SPOT"

rds_instance_class = "db.t3.small"
rds_multi_az       = false

ecr_image_mutability = "MUTABLE"
log_retention_days   = 14
