resource "aws_subnet" "subnets-public" {
  vpc_id            = "${aws_vpc.vpc.id}"
  availability_zone = "${data.aws_availability_zones.frankfurt.names[0]}"

  cidr_block              = "${cidrsubnet(aws_vpc.vpc.cidr_block, 8, 10)}"
  map_public_ip_on_launch = true

  tags = {
    Name = "Training ${var.Training} - Bastion Subnet"
    Training = "${var.Training}"
  }
}

resource "aws_route_table_association" "public-to-rt" {
  subnet_id      = "${aws_subnet.subnets-public.id}"
  route_table_id = "${aws_route_table.public-rt.id}"
}
