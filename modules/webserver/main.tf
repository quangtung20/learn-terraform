resource "aws_security_group" "myapp_sg" {
  name   = "myapp-sg"
  vpc_id = var.vpc_id

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
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.myapp_sg.id]
  availability_zone           = var.avail_zone
  associate_public_ip_address = true
  key_name                    = data.aws_key_pair.server_keypair.key_name
  user_data                   = file("entry-script.sh")
  tags = {
    Name : "${var.env_prefix}_instance"
  }
}
