provider "aws" {
    region = "us-east-1"
}

resource "aws_vpc" "container_vpc" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name: "container_vpc"
    }
}

resource "aws_subnet" "private_containner_subnet" {
    cidr_block = "10.0.5.0/24"
    vpc_id = aws_vpc.container_vpc.id
    tags = {
        Name: "private_containner_subnet"
    }
    availability_zone = var.new_subnet_az[1].az
}

data "aws_vpc" "existing_vpc" {
    id = "vpc-0939fac2ccc0cf001"
}

variable "new_subnet_az" {
    description = "subnet az"
    type = list(object({az=string}))
}

resource "aws_subnet" "public_container_subnet" {
    vpc_id = data.aws_vpc.existing_vpc.id
    cidr_block = "10.0.6.0/24"
    tags = {
      Name: "public_container_subnet"
    }
    availability_zone = var.new_subnet_az[0].az
}

resource "aws_subnet" "public_container_subnet2" {
    vpc_id = data.aws_vpc.existing_vpc.id
    cidr_block = "10.0.7.0/24"
    tags = {
      Name: "public_container_subnet2"
    }
    availability_zone = var.new_subnet_az[1].az
}


output "current_vpc" {
    value = aws_vpc.container_vpc.id
}