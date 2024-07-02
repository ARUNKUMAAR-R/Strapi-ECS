resource "aws_vpc" "strapi_vpc" {
  cidr_block = "172.18.0.0/16"
  tags = {
    name = "vpc-strapi"
  }
}

resource "aws_subnet" "public_subnet1" {
  vpc_id            = aws_vpc.strapi_vpc.id
  cidr_block        = "172.18.1.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_internet_gateway" "strapi_igw" {
  vpc_id = aws_vpc.strapi_vpc.id
}



resource "aws_route_table" "public_subnet1_rt" {
  vpc_id = aws_vpc.strapi_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.strapi_igw.id
  }
}


resource "aws_route_table_association" "public_subnet1_rt" {
  subnet_id      = aws_subnet.public_subnet1.id
  route_table_id = aws_route_table.public_subnet1_rt.id
}
