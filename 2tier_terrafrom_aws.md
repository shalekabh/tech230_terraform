# CODE FOR 2 TIER ARCHITECTURE

## INCLUDES VPC, IGW, ROUTE TABLE, SUBNETS, SECURITY GROUPS, INSTANCES AND REVERSE PROXY

```
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

# Create app security group

resource "aws_security_group" "tech230_shaleka_allow_ssh_HTTP_3000_mongodb" {
  name        = "tech230_shaleka_allow_ssh_HTTP_3000_mongodb"
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

  ingress {
    description      = "Mongo db"
    from_port        = 21017
    to_port          = 21017
    protocol         = "TCP"
    cidr_blocks      = ["10.0.3.0/24"]

  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

  tags = {
    Name = "tech230_shaleka_allow_ssh_HTTP_3000_mongodb_tf"
  }
}

# Create DB SG

resource "aws_security_group" "tech230_shaleka_allow_ssh_27017" {
  name        = "tech230_shaleka_allow_ssh_27017"
  description = "Allow ssh_21017 inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "TCP"
    cidr_blocks      = ["10.0.2.0/24"]

  }

  ingress {
    description      = "Mongo db"
    from_port        = 27017
    to_port          = 27017
    protocol         = "TCP"
    cidr_blocks      = ["10.0.2.0/24"]

  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]

  }

  tags = {
    Name = "tech230_shaleka_allow_ssh_27017_tf"
  }
}

# Git bash must have admin access
# Launch an ec2 instance




# Which resources

resource "aws_instance" "db_instance"{

# Which ami - ubuntu 18.04

	ami = "ami-08c604ba2abb6c6f1"	

# Which type of instance

	instance_type = "t2.micro"

# Do you need public ip

	associate_public_ip_address = true	


# VPC Allows instance SG

	vpc_security_group_ids = [aws_security_group.tech230_shaleka_allow_ssh_27017.id]

# Specify which subnet to launch in

	subnet_id = aws_subnet.private.id

# Private IP

	private_ip = "10.0.3.31"

# What would you like to name it

	tags = {
	   Name = "tech230-shaleka-terraform-db"
	}
}


resource "aws_instance" "app_instance"{

# Which ami - ubuntu 18.04

        ami = "ami-0136ddddd07f0584f"

# Which type of instance

        instance_type = "t2.micro"

# Do you need public ip

        associate_public_ip_address = true

# VPC Allows instance SG

        vpc_security_group_ids = [aws_security_group.tech230_shaleka_allow_ssh_HTTP_3000_mongodb.id]

# Specify which subnet to launch in

        subnet_id = aws_subnet.public.id

# Depends on db

	depends_on = [aws_instance.db_instance]
# What would you like to name it

        tags = {
           Name = "tech230-shaleka-terraform-app"
        }

# Edit user data to run app

	user_data = <<EOF
#!/bin/bash
 
# Update the sources list
		sudo apt-get update -y
 
# upgrade any packages available
		sudo apt-get upgrade -y
 
# install nginx
		sudo apt-get install nginx -y
 
# setup nginx reverse proxy
		sudo apt install sed
# $ and / characters must be escaped by putting a backslash before them
		sudo sed -i "s/try_files \$uri \$uri\/ =404;/proxy_pass http:\/\/localhost:3000\/;/" /etc/nginx/sites-available/default
# restart nginx to get reverse proxy working
		sudo systemctl restart nginx
 
# install git
		sudo apt-get install git -y
 
# install nodejs
# next line used to be: sudo apt-get install python-software-properties
		sudo apt-get install python-software-common
		curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
		sudo apt-get install nodejs -y
 

# create global env variable (so app vm can connect to db)
#echo "Setting environment variable DB_HOST..."
 
#echo "export DB_HOST=mongodb://10.0.3.37:27017/posts" >> ~/.bashrc # change IP to be the DB IP
#source ~/.bashrc
		export DB_HOST=mongodb://10.0.3.31:27017/posts
 
# clone repo with app folder into folder called 'repo'
		git clone https://github.com/daraymonsta/CloudComputingWithAWS repo
 
# install the app (must be after db vm is finished provisioning)
		cd repo/app
		npm install
 
# seed database
		echo "Clearing and seeding database..."
		node seeds/seed.js
		echo "  --> Done!"
 
# start the app (could also use 'npm start')
 
# using pm2
# install pm2
		sudo npm install pm2 -g
# kill previous app background processes
		pm2 kill
# start the app in the background with pm2
		pm2 start app.js

	EOF	

}
```