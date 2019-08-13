resource "aws_nat_gateway" "private-nat" {
  allocation_id = "${aws_eip.nat-eip.id}"
  subnet_id     = "${aws_subnet.subnets-public.*.id[0]}"

  tags = {
    Name = "Training ${var.Training} - Private NAT"
    Training = "${var.Training}"
  }
}

resource "aws_eip" "nat-eip" {
  vpc      = true

  tags = {
    Name = "Training ${var.Training} - NAT Internet IP"
    Training = "${var.Training}"
  }
}

resource "aws_route" "private_route_to_nat" {
  route_table_id  = "${data.aws_vpc.vpc.main_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = "${aws_nat_gateway.private-nat.id}"
}