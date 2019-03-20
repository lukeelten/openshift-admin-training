resource "aws_instance" "app-node" {
  depends_on      = ["aws_internet_gateway.igw"]

  ami             = "${data.aws_ami.centos.id}"
  instance_type   = "${var.Types["App"]}"
  key_name        = "${aws_key_pair.public-key.key_name}"
  user_data       = "${file("assets/init.sh")}"

  vpc_security_group_ids = ["${aws_security_group.nodes-sg.id}"]
  subnet_id = "${aws_subnet.subnets-public.*.id[(count.index % aws_subnet.subnets-public.count)]}"

  count = "${var.Counts["App"]}"

  root_block_device {
    volume_type = "gp2"
    volume_size = 40
  }

  lifecycle {
    create_before_destroy = true
  }

  tags {
    Type = "app"
    Name = "${var.ProjectName} - Application Node ${count.index + 1}"
    Project = "${var.ProjectName}"
    ProjectId = "${var.ProjectId}"
  }
}
