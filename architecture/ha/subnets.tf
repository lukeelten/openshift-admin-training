resource "aws_subnet" "subnets-public" {
  count = "${length(data.aws_availability_zones.frankfurt.names)}"

  vpc_id            = "${data.aws_vpc.vpc.id}"
  availability_zone = "${data.aws_availability_zones.frankfurt.names[count.index]}"

  cidr_block              = "${cidrsubnet(data.aws_vpc.vpc.cidr_block, 8, (1 + count.index))}"
  map_public_ip_on_launch = true

  tags = {
    Name = "Training ${var.Training} - Public Subnet ${count.index + 1}"
    Training = "${var.Training}"
  }
}

resource "aws_route_table_association" "public-to-rt" {
  count = "${length(aws_subnet.subnets-public)}"

  subnet_id      = "${aws_subnet.subnets-public.*.id[count.index]}"
  route_table_id = "${data.aws_route_table.public-rt.id}"
}


resource "aws_subnet" "subnets-private" {
  count = "${length(data.aws_availability_zones.frankfurt.names)}"

  vpc_id            = "${data.aws_vpc.vpc.id}"
  availability_zone = "${data.aws_availability_zones.frankfurt.names[count.index]}"

  cidr_block              = "${cidrsubnet(data.aws_vpc.vpc.cidr_block, 8, (4 + count.index))}"
  map_public_ip_on_launch = false

  tags = {
    Name = "Training ${var.Training} - Private Subnet ${count.index}"
    Training = "${var.Training}"
  }
}

resource "aws_route_table_association" "private-to-rt" {
  count = "${length(aws_subnet.subnets-private)}"

  subnet_id      = "${aws_subnet.subnets-private.*.id[count.index]}"
  route_table_id = "${data.aws_vpc.vpc.main_route_table_id}"
}