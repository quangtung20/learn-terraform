provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "myapp_vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name : "${var.env_prefix}_vpc"
  }
}

module "myapp_subnet" {
  source            = "./modules/subnet"
  subnet_cidr_block = var.subnet_cidr_block
  env_prefix        = var.env_prefix
  avail_zone        = var.avail_zone
  vpc_id            = aws_vpc.myapp_vpc.id
}

module "myapp_web_server" {
  source        = "./modules/webserver"
  vpc_id        = aws_vpc.myapp_vpc.id
  env_prefix    = var.env_prefix
  ami_owner_id  = var.ami_owner_id
  key_pair_id   = var.key_pair_id
  instance_type = var.instance_type
  avail_zone    = var.avail_zone
  subnet_id     = module.myapp_subnet.subnet.id
}
