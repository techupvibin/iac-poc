variable "aws_region"    { default = "ap-southeast-2" }
variable "project_name"  { default = "myapp" }
variable "environment"   { default = "sandbox" }
variable "vpc_cidr"      { default = "10.0.0.0/16" }
variable "azs"           { type = list(string); default = ["ap-southeast-2a", "ap-southeast-2b"] }
variable "public_subnets"  { type = list(string); default = ["10.0.1.0/24", "10.0.2.0/24"] }
variable "private_subnets" { type = list(string); default = ["10.0.11.0/24", "10.0.12.0/24"] }
variable "domain_name"          { default = "" }
variable "hosted_zone_id"       { default = "" }
variable "create_route53_record" { type = bool; default = false }
variable "frontend_image"  { default = "nginx:latest" }
variable "backend_image"   { default = "nginx:latest" }
variable "frontend_port"   { default = 3000 }
variable "backend_port"    { default = 4000 }
variable "task_cpu"        { default = "256" }
variable "task_memory"     { default = "512" }
variable "desired_count"   { default = 1 }
variable "min_capacity"    { default = 1 }
variable "max_capacity"    { default = 2 }
variable "capacity_provider" { default = "FARGATE_SPOT" }
variable "rds_instance_class"  { default = "db.t3.micro" }
variable "rds_multi_az"        { type = bool; default = false }
variable "rds_deletion_protection" { type = bool; default = false }
variable "ecr_image_mutability"    { default = "MUTABLE" }
variable "log_retention_days"      { default = 7 }
