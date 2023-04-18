# Provision private subnets in custom VPC
variable "private_cidr_blocks" {}
# Provision public subnets in custom VPC
variable "public_cidr_blocks" {}
# VPC CIDR range
variable "vpc_cidr" {}
# Default tags
variable "default_tags" {}
# Prefix to identify resources
 variable "prefix" {}
# Variable to signal the current environment 
variable "env" {}
