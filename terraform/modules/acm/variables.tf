
variable "project_name"   {}
variable "environment"    {}
variable "domain_name"    { default = "" }
variable "hosted_zone_id" { default = "" }
variable "create_cert"    { type = bool; default = false }
