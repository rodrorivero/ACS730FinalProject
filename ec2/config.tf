#thsi is the config file for terraform ec2
terraform {
  backend "s3" {
    bucket = "group11bucket"            // Bucket from where to GET Terraform State
    key    = "ec2/terraform.tfstate" // Object name in the bucket to GET Terraform State
    region = "us-east-1"                       // Region where bucket created
  }
}
