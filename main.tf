provider "aws" {
  region = "us-east-1"
}

variable "vpc_cidr_block" {}
variable "subnet_cidr_block" {}
variable "avail_zone" {}
variable "env_prefix" {}
variable "instance_type" {}
variable "ami_owner_id" {}
variable "key_pair_id" {}
variable "private_key_location" {}

resource "aws_vpc" "myapp_vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name : "${var.env_prefix}_vpc"
  }
}

resource "aws_subnet" "myapp_subnet" {
  cidr_block = var.subnet_cidr_block
  vpc_id     = aws_vpc.myapp_vpc.id
  tags = {
    Name : "${var.env_prefix}_subnet"
  }
  availability_zone = var.avail_zone
}

resource "aws_route_table" "myapp-route-table" {
  vpc_id = aws_vpc.myapp_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myapp_igw.id
  }
  tags = {
    Name : "${var.env_prefix}_rtb"
  }
}

resource "aws_internet_gateway" "myapp_igw" {
  vpc_id = aws_vpc.myapp_vpc.id
  tags = {
    Name : "${var.env_prefix}_igw"
  }
}

resource "aws_route_table_association" "a_rtb_subnet" {
  subnet_id      = aws_subnet.myapp_subnet.id
  route_table_id = aws_route_table.myapp-route-table.id
}

resource "aws_security_group" "myapp_sg" {
  name   = "myapp-sg"
  vpc_id = aws_vpc.myapp_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    prefix_list_ids = []
  }

  tags = {
    Name = "${var.env_prefix}_sg"
  }
}

data "aws_ami" "latest_amazon_linux_image" {
  most_recent = true
  owners      = [var.ami_owner_id]
  filter {
    name   = "name"
    values = ["amzn2-ami-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_key_pair" "server_keypair" {
  key_pair_id = var.key_pair_id
}

resource "aws_instance" "myapp" {
  ami                         = data.aws_ami.latest_amazon_linux_image.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.myapp_subnet.id
  vpc_security_group_ids      = [aws_security_group.myapp_sg.id]
  availability_zone           = var.avail_zone
  associate_public_ip_address = true
  key_name                    = data.aws_key_pair.server_keypair.key_name
  # user_data                   = file("entry-script.sh")
  tags = {
    Name : "${var.env_prefix}_instance"
  }
  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ec2-user"
    private_key = file(var.private_key_location)
  }

  provisioner "file" {
    source      = "entry-script.sh"
    destination = "/home/entry-script.sh"
  }

  provisioner "remote-exec" {
    script = file("entry-script.sh")
  }

  provisioner "local-exec" {
    command = "echo tung"
  }
}

output "output1" {
  value = data.aws_ami.latest_amazon_linux_image.name
}

output "output2" {
  value = data.aws_key_pair.server_keypair
}
