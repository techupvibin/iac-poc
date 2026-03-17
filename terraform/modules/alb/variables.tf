
variable "project_name"       {}
variable "environment"        {}
variable "vpc_id"             {}
variable "public_subnet_ids"  { type = list(string) }
variable "alb_sg_id"          {}
variable "frontend_port"      { default = 3000 }
variable "backend_port"       { default = 4000 }
variable "certificate_arn"    { default = "" }
variable "create_https"       { type = bool; default = false }
