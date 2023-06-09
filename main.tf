# To create a service on aws

# Launch an ec2 in Ireland

# Terraform to download required packages

# Terraform init

provider "aws" {

# Which regions
	region = "eu-west-1"
}


# Create VPC

resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "tech230-shaleka-terraform-vpc"
  }
}


# Create internet gateway

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "tech230-shaleka-terraform-IGW"
  }
}


# Create subnets


resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "eu-west-1a"

  tags = {
    Name = "tech230-shaleka-terraform-pubsub"
  }
}

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "eu-west-1b"

  tags = {
    Name = "tech230-shaleka-terraform-privsub"
  }
}


# Create a route table

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id 

  }

  route {
    ipv6_cidr_block        = "::/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "tech230-shaleka-terraform-RTPub"
  }
}

# Associate route table with subnet and internet gateway

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Create security group

resource "aws_security_group" "allow_ssh_HTTP_3000" {
  name        = "allow_ssh_HTTP_3000"
  description = "Allow ssh_HTTP_3000 inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "TCP"
    cidr_blocks      = ["10.0.0.0/16"]
    
  }

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "TCP"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

  ingress {
    description      = "3000"
    from_port        = 3000
    to_port          = 3000
    protocol         = "TCP"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }



  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

  tags = {
    Name = "tech230_shaleka_allow_ssh_HTTP_3000_tf"
  }
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

# VPC Allows instance SG

	vpc_security_group_ids = [aws_security_group.allow_ssh_HTTP_3000.id]

# Specify which subnet to launch in

	subnet_id = aws_subnet.public.id
# What would you like to name it

	tags = {
	   Name = "tech230-shaleka-terraform-app"
	}
}
