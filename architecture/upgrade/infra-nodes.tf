resource "aws_instance" "infra-node" {
  depends_on      = ["aws_internet_gateway.igw", "aws_nat_gateway.private-nat", "aws_route.private_route_to_nat"]

  ami = "${data.aws_ami.centos.id}"
  instance_type   = "${var.Types["Infra"]}"
  key_name        = "heinlein-training-${var.Training}"
  user_data       = "${file("assets/init.sh")}"
  vpc_security_group_ids = ["${aws_security_group.nodes-sg.id}", "${aws_security_group.infra-sg.id}"]
  subnet_id = "${aws_subnet.subnets-private.*.id[(count.index % aws_subnet.subnets-private.count)]}"

  count = "${var.Counts["Infra"]}"

  root_block_device {
    volume_type = "gp2"
    volume_size = 40
  }

  lifecycle {
    create_before_destroy = true
  }

  tags {
    Type = "infra"
    Name = "Training ${var.Training} - Infrastructure Node ${count.index + 1}"
    Training = "${var.Training}"
  }
}

resource "aws_lb_target_group_attachment" "infra-lb-http" {
  target_group_arn = "${aws_lb_target_group.external-tg-http.arn}"
  target_id        = "${aws_instance.infra-node.*.id[count.index]}"
  port             = "${aws_lb_target_group.external-tg-http.port}"

  count = "${var.Counts["Infra"]}"
}


resource "aws_lb_target_group_attachment" "infra-lb-https" {
  target_group_arn = "${aws_lb_target_group.external-tg-https.arn}"
  target_id        = "${aws_instance.infra-node.*.id[count.index]}"
  port             = "${aws_lb_target_group.external-tg-https.port}"

  count = "${var.Counts["Infra"]}"
}
