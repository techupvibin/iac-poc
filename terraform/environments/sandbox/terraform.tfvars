
aws_region    = "ap-southeast-2"
project_name  = "myapp"
environment   = "sandbox"

vpc_cidr        = "10.0.0.0/16"
azs             = ["ap-southeast-2a", "ap-southeast-2b"]
public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnets = ["10.0.11.0/24", "10.0.12.0/24"]

create_route53_record = false
# domain_name    = "sandbox.myapp.example.com"
# hosted_zone_id = "Z1234567890ABC"

task_cpu       = "256"
task_memory    = "512"
desired_count  = 1
min_capacity   = 1
max_capacity   = 2
capacity_provider = "FARGATE_SPOT"

rds_instance_class   = "db.t3.micro"
rds_multi_az         = false
rds_deletion_protection = false

ecr_image_mutability = "MUTABLE"
log_retention_days   = 7
