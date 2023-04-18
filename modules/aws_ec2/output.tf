# Add output variables
output "public_vm1" {
  value = aws_instance.public_vm1.public_ip
}
output "bastion_ip" {

value = aws_instance.bastion_vm.public_ip 
}

output "public_vm3_vm4" {
  value = aws_instance.public_vms_blank[*].public_ip
}

output "private_vms_ips" {
  value = aws_instance.private_vms[*].private_ip
}



