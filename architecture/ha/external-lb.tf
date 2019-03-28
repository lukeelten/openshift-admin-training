
resource "aws_lb" "external-lb" {
  depends_on      = ["aws_internet_gateway.igw"]
  name = "training-${var.Training}-external-lb"
  load_balancer_type = "network"

  subnets = ["${aws_subnet.subnets-public.*.id}"]

  tags {
    Type = "external"
    Name = "Training ${var.Training} - Public LB"
    Training = "${var.Training}"
  }
}

resource "aws_lb_target_group" "external-tg-http" {
  name     = "training-${var.Training}-external-tg-http"
  port     = 80
  protocol = "TCP"
  vpc_id   = "${aws_vpc.vpc.id}"

  tags {
    Name = "Training ${var.Training} - Public HTTP Traffic"
    Training = "${var.Training}"
  }

  health_check {
    protocol = "TCP"
    interval = 10
    healthy_threshold = 2
    unhealthy_threshold = 3
  }
}

resource "aws_lb_target_group" "external-tg-https" {
  name     = "training-${var.Training}-external-tg-https"
  port     = 443
  protocol = "TCP"
  vpc_id   = "${aws_vpc.vpc.id}"

  tags {
    Name = "Training ${var.Training} - Public HTTPS Traffic"
    Training = "${var.Training}"
  }

  health_check {
    protocol = "TCP"
    interval = 10
    healthy_threshold = 2
    unhealthy_threshold = 3
  }
}

resource "aws_lb_target_group" "external-tg-master" {
  name     = "training-${var.Training}-external-tg-master"
  port     = 8443
  protocol = "TCP"
  vpc_id   = "${aws_vpc.vpc.id}"

  tags {
    Name = "Training ${var.Training} - Public Master Traffic"
    Training = "${var.Training}"
  }

  health_check {
    protocol = "TCP"
    interval = 10
    healthy_threshold = 2
    unhealthy_threshold = 3
  }
}

resource "aws_lb_listener" "external-listener-master" {
  load_balancer_arn = "${aws_lb.external-lb.arn}"
  port              = "8443"
  protocol          = "TCP"

  default_action {
    target_group_arn = "${aws_lb_target_group.external-tg-master.arn}"
    type             = "forward"
  }
}

resource "aws_lb_listener" "external-listener-http" {
  load_balancer_arn = "${aws_lb.external-lb.arn}"
  port              = "80"
  protocol          = "TCP"

  default_action {
    target_group_arn = "${aws_lb_target_group.external-tg-http.arn}"
    type             = "forward"
  }
}

resource "aws_lb_listener" "external-listener-https" {
  load_balancer_arn = "${aws_lb.external-lb.arn}"
  port              = "443"
  protocol          = "TCP"

  default_action {
    target_group_arn = "${aws_lb_target_group.external-tg-https.arn}"
    type             = "forward"
  }
}