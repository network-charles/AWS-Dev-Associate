resource "aws_vpc" "elastic_beanstalk" {
  cidr_block           = "10.1.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "elastic_beanstalk"
  }
}

resource "aws_subnet" "public1" {
  vpc_id                  = aws_vpc.elastic_beanstalk.id
  cidr_block              = "10.1.1.0/24"
  availability_zone       = "eu-west-2a"
  map_public_ip_on_launch = true

  tags = {
    "Name" = "public1"
  }
}

resource "aws_subnet" "public2" {
  vpc_id                  = aws_vpc.elastic_beanstalk.id
  cidr_block              = "10.1.2.0/24"
  availability_zone       = "eu-west-2b"
  map_public_ip_on_launch = true

  tags = {
    "Name" = "public2"
  }
}

resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.elastic_beanstalk.id

  tags = {
    "Name" = "IGW"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.elastic_beanstalk.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW.id
  }

  tags = {
    "Name" = "public"
  }
}

resource "aws_route_table_association" "RTA1" {
  subnet_id      = aws_subnet.public1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "RTA2" {
  subnet_id      = aws_subnet.public2.id
  route_table_id = aws_route_table.public.id
}
