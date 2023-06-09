https://registry.terraform.io/providers/hashicorp/terraform/latest/docs

First download terraform :

Run the .exe application as administrator – nothing will tell you when its done, just be aware of that.

Next set a path in the PATH in your environment variables and system variables on your host operating system. (the path is the absolute path to the terraform.exe ( I had to put my terraform.exe in my windows system32 directory, so my path was /C:/windows/system32)):

Next in this section create new environment variables for your access key and secret key:

Save and exit:

If it says you don’t have permission still try to use this code in your command prompt 
```
[Environment]::SetEnvironmentVariable("AWS_ACCESS_KEY_ID", "your-access-key", "User")
[Environment]::SetEnvironmentVariable("AWS_SECRET_ACCESS_KEY", "your-secret-access-key", "User")
```

Next open your git bash terminal as admin.

Run the command terraform –version to see if its installed correctly.

Next make sure youre in the right directory and create the main.tf terraform:

```nano main.tf```

The following are the steps we want to achieve with terraform:

```
# To create a service on aws cloud

# Launch a ec2 in Ireland

#terraform to download required packages

provider “aws”  {

# which regions of AWS

	region = “eu-west-1”
}

# gitbash must have admi access

# launch an ec2

# which rescource

resource “aws_instance” “app_instance”{

#which ami – ubuntu 18.04

	ami = ami-00e8ddf087865b27f

#which type of instance t2.micro

	instance_type = “t2.micro”

#do you need public ip = yes

associate_public_ip_address = true

# what would you like to call it

	tags  = {
		Name = “shaleka-tech230-terraform-app
    }
}
```
Save and exit:

Run ```terraform init``` to initialise terraform in the directory.

Run ```terraform plan``` to check what the changes will be and if there are any errors you will receive feedback.

Run ```terraform apply``` if plan passed all the checks, this will build all the infrastructure in the main.tf folder.
Once this process has been completed. You ca check your aws webpage to see if the ec2 instance has launched.

If it has launched then we can run ```terraform destroy``` to terminate the instance.

Now we want to add more to our main.tf file:

```nano main.tf```

The following is the updated things we want to do:

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
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "TCP"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "3000"
    from_port        = 3000
    to_port          = 3000
    protocol         = "TCP"
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

  tags = {
    Name = "allow_ssh_HTTP_3000_tf"
  }
}

# gitbash must have admi access

# launch an ec2

# which rescource

resource “aws_instance” “app_instance”{

#which ami – ubuntu 18.04

	ami = ami-00e8ddf087865b27f

#which type of instance t2.micro

	instance_type = “t2.micro”

#do you need public ip = yes

associate_public_ip_address = true

# Connect VPC to SG. Attach the security group created earlier

vpc_security_group_ids = [aws_security_group.allow_ssh_HTTP_3000.id]  

# Specify the public subnet ID where you want the instance to be launched

subnet_id = aws_subnet.public.id  

# what would you like to call it

	tags  = {
		Name = “shaleka-tech230-terraform-app
    }
}
```

This includes the VPC, IGW, 1RT, Pub and private subnet, SG-22-80-3000, ec2 instance

### Plan and apply.

Run ```terraform plan```:

run ```terraform apply```

![Alt text](pics/tf%20vpc.png)
![Alt text](pics/tf%20igw.png)
![Alt text](pics/tf%20subnets.png)
![Alt text](pics/tf%20subnet%20and%20association.png)
![Alt text](pics/tf%20edit%20routes.png)
![Alt text](pics/tf%20sg.png)
![Alt text](pics/tf%20ports.png)
![Alt text](pics/tf%20instance.png)
![Alt text](pics/tf%20instance%20location.png)