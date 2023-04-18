# Terraform Config file (main.tf). This has provider block (AWS) and config for provisioning one EC2 instance resource.  

terraform {
required_providers {
  aws = {
  source = "hashicorp/aws"
  version = ">= 3.27"
 }
}

  required_version = ">=0.14"
} 
provider "aws" {
  profile = "default"
  region = "us-east-1"
}

data "terraform_remote_state" "networking" { // This is to use Outputs from Remote State
  backend = "s3"
  config = {
    bucket = "group11bucket"            // Bucket from where to GET Terraform State
    key    = "network/terraform.tfstate"// Region where bucket created
    region = "us-east-1"
  }
}

# Data source for AMI id
data "aws_ami" "latest_amazon_linux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Data source for availability zones in us-east-1
data "aws_availability_zones" "available" {
  state = "available"
}

# Define tags locally
locals {
  default_tags = merge(var.default_tags, { "env" = var.env })
  name_prefix  = "${var.prefix}-${var.env}"

}

# Adding SSH  key to instance
resource "aws_key_pair" "key_ssh" {

  key_name   = ("FinalKey")
  public_key = file("FinalKey.pub")
}

#Security Group bastion
resource "aws_security_group" "bastion" {
  name        = "bastion_sg"
  description = "Allow SSH external inbound SSH and HTTP"
  vpc_id      = data.terraform_remote_state.networking.outputs.vpc_id 

  ingress {
    description      = "SSH from bastion"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  
  ingress {
    description      = "SSH from bastion"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(local.default_tags,
    {
      "Name" = "Bastion SGRP"
    }
  )
}

#Security Group public vms
resource "aws_security_group" "public_vms" {
  name        = "allow_ssh"
  description = "Allow external inbound HTTP"
  vpc_id      = data.terraform_remote_state.networking.outputs.vpc_id 

  ingress {
    description      = "SSH from bastion"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(local.default_tags,
    {
      "Name" = "Public SGRP"
    }
  )
}

#Security Group private vms
resource "aws_security_group" "private_vms" {
  name        = "allow_http_ssh"
  description = "Allow HTTP and SSH inbound traffic"
  vpc_id      = data.terraform_remote_state.networking.outputs.vpc_id 

  ingress {
    description      = "SSH from public subnet"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [data.terraform_remote_state.networking.outputs.public_subnet_cidrs[1]]
    ipv6_cidr_blocks = ["::/0"]
  }
  
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = merge(local.default_tags,
    {
      "Name" = "Private SGRP"
    }
  )
}


# Provitioning private VMS

resource "aws_instance" "private_vms" {
    count                  = 2
    ami                    = data.aws_ami.latest_amazon_linux.id
    instance_type          = lookup(var.instance_type, var.env)
    key_name               = aws_key_pair.key_ssh.key_name
    security_groups        = [aws_security_group.private_vms.id]
    subnet_id              = data.terraform_remote_state.networking.outputs.private_subnet_ids[0]
    associate_public_ip_address = false
    user_data = templatefile("${path.module}/install_httpd.sh.tpl",
      {
        env    = upper(var.env),
        prefix = upper(var.prefix)
      }
    )
   lifecycle {
    create_before_destroy = true
   }  

  tags = merge(local.default_tags, 
  {
  "Name" = "VM${count.index + 1} - Private"
    
  }
  )
  

}

# Provitioning bastion VM

resource "aws_instance" "bastion_vm" {

    ami                    = data.aws_ami.latest_amazon_linux.id
    instance_type          = lookup(var.instance_type, var.env)
    key_name               = aws_key_pair.key_ssh.key_name
    security_groups        = [aws_security_group.bastion.id]
    subnet_id              = data.terraform_remote_state.networking.outputs.public_subnet_ids[2]
    associate_public_ip_address = true
    provisioner "file" {
        source      = "FinalKey"
        destination = "/home/ec2-user/FinalKey"
        connection {
            type        = "ssh"
            user        = "ec2-user"
            private_key = file("FinalKey")
            host        = "${self.public_ip}"
        }
    }
    user_data = <<EOF
    #!/bin/bash
    chmod 700 /home/ec2-user/FinalKey
    ls -lart /home/ec2-user/FinalKey > /home/ec2-user/log.txt
    yum -y update
    yum -y install httpd
    echo "<h1>Final Group Assignment</h1><p>My private IP is <font color="blue">\$myip</font></p><ul><li>Mohamed Zaheer Fasly</li><li>Stanley Amaobi Nnodu</li><li>Carlos Rodrigo Rivero</li></ul>"  >  /var/www/html/index.html
    sudo systemctl start httpd
    sudo systemctl enable httpd
    EOF

   lifecycle {
    create_before_destroy = true
   }  

  tags = merge(local.default_tags,
    {
      "Name" = "VM2 - Bastion"
    }
  )
}


# Provitioning private VMS

resource "aws_instance" "public_vm1" {
    
    ami                    = data.aws_ami.latest_amazon_linux.id
    instance_type          = lookup(var.instance_type, var.env)
    key_name               = aws_key_pair.key_ssh.key_name
    security_groups        = [aws_security_group.public_vms.id]
    subnet_id              = data.terraform_remote_state.networking.outputs.public_subnet_ids[0]
    associate_public_ip_address = true
    user_data = templatefile("${path.module}/install_httpd.sh.tpl",
      {
        env    = upper(var.env),
        prefix = upper(var.prefix)
      }
    )
    root_block_device {
      encrypted = var.env == "prod" ? true : false
    }
    lifecycle {
      create_before_destroy = true
    }  
    tags = merge(local.default_tags,
    {
      "Name" = "VM1 - Public"
    }
  )
}


resource "aws_instance" "public_vms_blank" {
    
    count                  = 2
    ami                    = data.aws_ami.latest_amazon_linux.id
    instance_type          = lookup(var.instance_type, var.env)
    key_name               = aws_key_pair.key_ssh.key_name
    security_groups        = [aws_security_group.public_vms.id]
    subnet_id              = data.terraform_remote_state.networking.outputs.public_subnet_ids[count.index +2]
    associate_public_ip_address = true

    lifecycle {
      create_before_destroy = true
    }  
    tags = merge(local.default_tags,
    {
      "Name" = "VM${count.index + 3} - Public"
    }
  )
}