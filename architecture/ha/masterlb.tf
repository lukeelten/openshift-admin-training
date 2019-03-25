
resource "aws_lb" "master-lb" {
  depends_on      = ["aws_internet_gateway.igw"]
  name = "training-${var.Training}-master-lb"
  load_balancer_type = "network"

  subnets = ["${aws_subnet.subnets-public.*.id}"]

  tags {
    Type = "master"
    Name = "Training ${var.Training} - Public Master LB"
    Training = "${var.Training}"
  }
}

resource "aws_lb_target_group" "master-lb-tg1" {
  name     = "training-${var.Training}-master-lb-tg1"
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
    // timeout = 10
    // 30 seconds for a target to become healthy
    healthy_threshold = 3
    // 30 seconds to detect unhealthy targets
    unhealthy_threshold = 3
  }
}

resource "aws_lb_listener" "master-lb-listener1" {
  load_balancer_arn = "${aws_lb.master-lb.arn}"
  port              = "8443"
  protocol          = "TCP"

  default_action {
    target_group_arn = "${aws_lb_target_group.master-lb-tg1.arn}"
    type             = "forward"
  }
}

resource "aws_lb_listener" "master-lb-listener2" {
  load_balancer_arn = "${aws_lb.master-lb.arn}"
  port              = "443"
  protocol          = "TCP"

  default_action {
    target_group_arn = "${aws_lb_target_group.master-lb-tg1.arn}"
    type             = "forward"
  }
}