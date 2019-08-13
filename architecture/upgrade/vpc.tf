resource "aws_vpc" "vpc" {
  cidr_block                       = "10.${var.Training}.0.0/16"
  enable_dns_hostnames             = true

  tags = {
    Name = "Training ${var.Training} - VPC"
    Training = "${var.Training}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags = {
    Name = "Training ${var.Training} - Internet Gateway"
    Training = "${var.Training}"
  }
}

resource "aws_route_table" "public-rt" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }

  tags = {
    Name = "Training ${var.Training} - Public Route Table"
    Training = "${var.Training}"
  }
}