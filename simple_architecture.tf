provider "aws" {
  region     = "us-east-1"
  access_key = "your_access_key_here"   # It is recommended to use envirionmental variables here
  secret_key = "your_secret_key_here"   # instead of putting the information in plaintext
}


/* The below code will create a VPC with the name "my_vpc"
   you can chang the name of the vpc and cidr_block as you see fit */

resource "aws_vpc" "my_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "MyVPC"
  }
}



/* The code below will create a subnet named "my_subnet" which is a 
   subnet of the 10.0.0.0/16 CIDR that we set for the VPC previously
   change the subnet name, and cidr_block as needed */

resource "aws_subnet" "my_subnet" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a" # Change as per your requirement

  tags = {
    Name = "MyPublicSubnet"
  }
}



/* The below code will create an internet gateway which will allow traffic 
   to the internet */

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "MyInternetGateway"
  }
}


/* The code below will create a route table which we will attach to our VPC
   this will allow us to create routes to our Internet Gateway, later we will
   need to add the route to the VPC peering connection

resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
    Name = "MyRouteTable"
  }
}

/* Below is the code that will attach our route table to the subnet we 
   created earlier */

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.my_subnet.id
  route_table_id = aws_route_table.my_route_table.id
}


/* Below is the code to create a security group that will allow HTTP, SSH
   and ICMP traffic from anywhere. Make sure to change this to your IP range
   if you plan on keeping this architecture up for security */
resource "aws_security_group" "my_sg" {
  name        = "allow_web"
  description = "Allow SSH, HTTP, and ICMP traffic"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "SSH"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "HTTP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "MySecurityGroup"
  }
}
