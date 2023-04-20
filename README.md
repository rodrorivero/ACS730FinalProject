# ACS730FinalProject - Group 11

Members:

*Mohamed Zaheer Fasly
*Stanley Amaobi Nnodu
*Sandra Buma
*Carlos Rodrigo Rivero

- Pre requisites:

Create a Clou9 environment for deploying 

- Steps to deploy:

1) Clone the Github repository on to your machine.
2) Change the bucket config located in files: ec2/config.tf and network/config.tf to your own bucket name
3) Create an shh Key file using: ssh-keygen FinalKey and copy both keys (public and private) to the paths: ec2/
4) Deploy the terraform code by using:
   cd ec2/
   terraform init
   terraform plan
   terraform apply
   cd network/
   terraform init
   terraform plan
   terraform apply
5) Verify the servers where deployed correctly
6) Deploy the ansible apache by executing:
   cd ansible/
   ansible-playbook -i aws_ec2.yaml playbook3.yaml
7) Verify the public web where deployed on the last 2 servers
   
    
