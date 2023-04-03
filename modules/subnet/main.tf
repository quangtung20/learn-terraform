resource "aws_subnet" "myapp_subnet" {
  cidr_block = var.subnet_cidr_block
  vpc_id     = var.vpc_id
  tags = {
    Name : "${var.env_prefix}_subnet"
  }
  availability_zone = var.avail_zone
}

resource "aws_route_table" "myapp-route-table" {
  vpc_id = var.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myapp_igw.id
  }
  tags = {
    Name : "${var.env_prefix}_rtb"
  }
}

resource "aws_internet_gateway" "myapp_igw" {
  vpc_id = var.vpc_id
  tags = {
    Name : "${var.env_prefix}_igw"
  }
}

resource "aws_route_table_association" "a_rtb_subnet" {
  subnet_id      = aws_subnet.myapp_subnet.id
  route_table_id = aws_route_table.myapp-route-table.id
}
