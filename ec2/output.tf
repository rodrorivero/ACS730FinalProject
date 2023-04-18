output "public_vm1" {
  value = module.ec2_instances.public_vm1
}
output "bastion_ip" {
  value = module.ec2_instances.bastion_ip
}
output "public_vm3_vm4" {
  value = module.ec2_instances.public_vm3_vm4
}
output "private_vms_ips" {
  value = module.ec2_instances.private_vms_ips
}

