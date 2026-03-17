
variable "project_name"       {}
variable "environment"        {}
variable "aws_region"         {}
variable "private_subnet_ids" { type = list(string) }
variable "ecs_sg_id"          {}
variable "frontend_tg_arn"    {}
variable "backend_tg_arn"     {}
variable "frontend_image"     {}
variable "backend_image"      {}
variable "frontend_port"      { default = 3000 }
variable "backend_port"       { default = 4000 }
variable "task_cpu"           { default = "256" }
variable "task_memory"        { default = "512" }
variable "desired_count"      { default = 1 }
variable "min_capacity"       { default = 1 }
variable "max_capacity"       { default = 2 }
variable "capacity_provider"  { default = "FARGATE_SPOT" }
variable "db_secret_arn"      {}
variable "app_secret_arn"     {}
variable "rds_endpoint"       {}
variable "s3_bucket_name"     {}
variable "log_retention_days" { default = 7 }
