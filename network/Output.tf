output "public_subnet_ids" {
  value = module.vpc-dev.public_subnet_id
}

output "private_subnet_ids" {
  value = module.vpc-dev.private_subnet_id
}

output "vpc_id" {
  value = module.vpc-dev.vpc_id
}

output "public_subnet_cidrs" {
  value = var.public_subnet_cidrs
}

output "private_subnet_cidrs" {
  value = var.private_subnet_cidrs
}

output "public_route_table" {
  value = module.vpc-dev.public_route_table 
}