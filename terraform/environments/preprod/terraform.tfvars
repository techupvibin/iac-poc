
aws_region    = "ap-southeast-2"
project_name  = "myapp"
environment   = "preprod"

vpc_cidr        = "10.2.0.0/16"
azs             = ["ap-southeast-2a", "ap-southeast-2b", "ap-southeast-2c"]
public_subnets  = ["10.2.1.0/24", "10.2.2.0/24", "10.2.3.0/24"]
private_subnets = ["10.2.11.0/24", "10.2.12.0/24", "10.2.13.0/24"]

create_route53_record = false

task_cpu      = "1024"
task_memory   = "2048"
desired_count = 2
min_capacity  = 2
max_capacity  = 6
capacity_provider = "FARGATE"

rds_instance_class = "db.t3.medium"
rds_multi_az       = true

ecr_image_mutability = "IMMUTABLE"
log_retention_days   = 30
