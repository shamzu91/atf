# Internet VPC
resource "aws_vpc" "testapp" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  
  enable_dns_hostnames = "true"
  enable_classiclink   = "false"
  tags = {
    Name = "testapp"
  }
}

# Subnets
resource "aws_subnet" "testapp-public-1" {
  vpc_id                  = aws_vpc.testapp.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "ap-south-1a"

  tags = {
    Name = "testapp-public-1"
  }
}

resource "aws_subnet" "testapp-public-2" {
  vpc_id                  = aws_vpc.testapp.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "ap-south-1b"

  tags = {
    Name = "testapp-public-2"
  }
}

resource "aws_subnet" "testapp-public-3" {
  vpc_id                  = aws_vpc.testapp.id
  cidr_block              = "10.0.3.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "ap-south-1c"

  tags = {
    Name = "testapp-public-3"
  }
}

resource "aws_subnet" "testapp-private-1" {
  vpc_id                  = aws_vpc.testapp.id
  cidr_block              = "10.0.4.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = "ap-south-1a"

  tags = {
    Name = "testapp-private-1"
  }
}

resource "aws_subnet" "testapp-private-2" {
  vpc_id                  = aws_vpc.testapp.id
  cidr_block              = "10.0.5.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = "ap-south-1b"

  tags = {
    Name = "testapp-private-2"
  }
}

resource "aws_subnet" "testapp-private-3" {
  vpc_id                  = aws_vpc.testapp.id
  cidr_block              = "10.0.6.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = "ap-south-1c"

  tags = {
    Name = "testapp-private-3"
  }
}

# Internet GW
resource "aws_internet_gateway" "testapp-gw" {
  vpc_id = aws_vpc.testapp.id

  tags = {
    Name = "testapp"
  }
}

# route tables
resource "aws_route_table" "testapp-public" {
  vpc_id = aws_vpc.testapp.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.testapp-gw.id
  }

  tags = {
    Name = "testapp-public-1"
  }
}

# route associations public
resource "aws_route_table_association" "testapp-public-1-a" {
  subnet_id      = aws_subnet.testapp-public-1.id
  route_table_id = aws_route_table.testapp-public.id
}

resource "aws_route_table_association" "testapp-public-2-a" {
  subnet_id      = aws_subnet.testapp-public-2.id
  route_table_id = aws_route_table.testapp-public.id
}

resource "aws_route_table_association" "testapp-public-3-a" {
  subnet_id      = aws_subnet.testapp-public-3.id
  route_table_id = aws_route_table.testapp-public.id
}

resource "aws_security_group" "ecs-instance" {
  vpc_id      = aws_vpc.testapp.id
  name        = "allow-ssh"
  description = "security group that allows ssh and all egress traffic"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "ecs-instance"
  }
}

resource "aws_security_group" "allow-db" {
  vpc_id      = aws_vpc.testapp.id
  name        = "allow-db"
  description = "allow-db"
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs-instance.id] # allowing access from our ecs instance
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    self        = true
  }
  tags = {
    Name = "allow-db"
  }
}

