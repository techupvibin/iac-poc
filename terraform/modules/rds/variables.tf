
variable "project_name"        {}
variable "environment"         {}
variable "private_subnet_ids"  { type = list(string) }
variable "rds_sg_id"           {}
variable "instance_class"      { default = "db.t3.micro" }
variable "multi_az"            { type = bool; default = false }
variable "deletion_protection" { type = bool; default = false }
variable "db_password_secret"  {}
