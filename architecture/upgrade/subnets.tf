resource "aws_subnet" "subnets-public" {
  count = "${length(data.aws_availability_zones.frankfurt.names)}"

  vpc_id            = "${aws_vpc.vpc.id}"
  availability_zone = "${data.aws_availability_zones.frankfurt.names[count.index]}"

  cidr_block              = "${cidrsubnet(aws_vpc.vpc.cidr_block, 8, (1 + count.index))}"
  map_public_ip_on_launch = true

  tags {
    Name = "${var.ProjectName} - Public Subnet ${count.index + 1}"
    Project = "${var.ProjectName}"
    ProjectId = "${var.ProjectId}"
  }
}

resource "aws_route_table_association" "public-to-rt" {
  count = "${aws_subnet.subnets-public.count}"

  subnet_id      = "${aws_subnet.subnets-public.*.id[count.index]}"
  route_table_id = "${aws_route_table.public-rt.id}"
}
