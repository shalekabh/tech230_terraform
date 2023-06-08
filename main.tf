# To create a service on aws

# Launch an ec2 in Ireland

# Terraform to download required packages

# Terraform init

provider "aws" {

# Which regions
	region = "eu-west-1"
}

# Git bash must have admin access

# Launch an ec2 instance

# Which resources

resource "aws_instance" "app_instance"{

# Which ami - ubuntu 18.04

	ami = "ami-00e8ddf087865b27f"	

# Which type of instance

	instance_type = "t2.micro"

# Do you need public ip

	associate_public_ip_address = true

# What would you like to name it

	tags = {
	   Name = "tech230-shaleka-terraform-app"
	}
}
