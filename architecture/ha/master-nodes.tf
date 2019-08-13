resource "aws_instance" "master-node" {
  depends_on      = ["aws_nat_gateway.private-nat", "aws_route.private_route_to_nat"]

  ami             = "${data.aws_ami.centos.id}"
  instance_type   = "${var.Types["Master"]}"
  key_name        = "heinlein-training-${var.Training}"
  user_data       = "${file("assets/init.sh")}"

  vpc_security_group_ids = ["${aws_security_group.nodes-sg.id}", "${aws_security_group.master-sg.id}"]
  subnet_id = "${aws_subnet.subnets-private.*.id[(count.index % length(aws_subnet.subnets-private))]}"

  count = "${var.Counts["Master"]}"

  root_block_device {
    volume_type = "gp2"
    volume_size = 50
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Type = "master"
    Name = "Training ${var.Training} - Master Node ${count.index + 1}"
    Training = "${var.Training}"
  }
}

resource "aws_lb_target_group_attachment" "master-to-master-lb" {
  target_group_arn = "${aws_lb_target_group.external-tg-master.arn}"
  target_id        = "${aws_instance.master-node.*.id[count.index]}"
  port             = 8443

  count = "${var.Counts["Master"]}"
}

resource "aws_lb_target_group_attachment" "master-to-internal-lb" {
  target_group_arn = "${aws_lb_target_group.internal-lb-master.arn}"
  target_id        = "${aws_instance.master-node.*.id[count.index]}"
  port             = 8443

  count = "${var.Counts["Master"]}"
}
