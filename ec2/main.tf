# Module to deploy basic networking for terraform1
module "ec2_instances" {
  source              = "../modules/aws_ec2"
  env                 = var.env
  instance_type       = var.instance_type
  prefix              = var.prefix
  default_tags        = var.default_tags
}