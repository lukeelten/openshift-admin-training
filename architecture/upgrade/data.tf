
data "aws_availability_zones" "frankfurt" {}

data "aws_ami" "centos" {
  most_recent = true

  filter {
    name   = "name"
    values = ["CentOS Linux 7 x86_64 HVM EBS ENA *"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["679593333241"] # CentOS official
}

data "aws_route53_zone" "existing-zone" {
  name = "${var.Zone}"
  private_zone = false
}

data "aws_vpc" "vpc" {
  cidr_block = "10.${var.Training}.0.0/16"

  tags = {
    Name = "Training ${var.Training} - VPC"
    Training = "${var.Training}"
  }
}

data "aws_route_table" "public-rt" {
  vpc_id = "${data.aws_vpc.vpc.id}"
  
  tags = {
    Name = "Training ${var.Training} - Public Route Table"
    Training = "${var.Training}"
  }
}

data "aws_security_group" "bastion-sg" {
  vpc_id = "${data.aws_vpc.vpc.id}"
  name = "training-${var.Training}-bastion-sg"
}