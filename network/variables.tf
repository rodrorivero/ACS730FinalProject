# Default tags
variable "default_tags" {
  default = {
    "Owner" = "Group11",
    "Type"   = "Networking"
  }
  type        = map(any)
  description = "Default tags to be applied to all AWS resources"
}

# Name prefix
variable "prefix" {
  type        = string
  default     = "FinalAssignment"
  description = "Name prefix"
}

# Provision public subnets in custom VPC
variable "public_subnet_cidrs" {
  default     = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24", "10.1.4.0/24"]
  type        = list(string)
  description = "Private Subnet CIDRs"
}

# Provision public subnets in custom VPC
variable "private_subnet_cidrs" {
  default     = ["10.1.5.0/24", "10.1.6.0/24"]
  type        = list(string)
  description = "Public Subnet CIDRs"
}

# VPC CIDR range DEV
variable "vpc_cidr" {
  default     = "10.1.0.0/16"
  type        = string
  description = "VPC Prod"
}

# Variable to signal the current environment 
variable "env" {
  default     = "prod"
  type        = string
  description = "Final Assignment"
}

