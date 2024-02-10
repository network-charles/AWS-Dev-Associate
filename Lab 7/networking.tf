resource "aws_vpc" "my_vpc" {
  cidr_block           = "172.16.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "my_vpc"
  }
}

resource "aws_subnet" "my_subnet_1" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "172.16.10.0/24"
  availability_zone       = "eu-west-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "my_subnet_1"
  }
}

resource "aws_subnet" "my_subnet_2" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "172.16.20.0/24"
  availability_zone       = "eu-west-2b"
  map_public_ip_on_launch = true

  tags = {
    Name = "my_subnet_2"
  }
}

resource "aws_internet_gateway" "IGW" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "IGW"
  }
}

resource "aws_route_table" "RT" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW.id
  }

  tags = {
    "name" = "RT"
  }
}

resource "aws_route_table_association" "RT_association" {
  count = 2
  # 1/2=0.5 odd, 2/2=1 even
  # if count.index is divided by 2 and the remainder is even, 
  # assign instance to aws_subnet.my_subnet_1.id, 
  # else aws_subnet.my_subnet_2.id
  subnet_id      = count.index % 2 == 0 ? aws_subnet.my_subnet_1.id : aws_subnet.my_subnet_2.id
  route_table_id = aws_route_table.RT.id
}
