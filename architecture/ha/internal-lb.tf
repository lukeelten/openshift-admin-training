
resource "aws_lb" "internal-lb" {
  depends_on      = ["aws_internet_gateway.igw"]
  name = "training-${var.Training}-api-internal-lb"
  load_balancer_type = "network"

  subnets = ["${aws_subnet.subnets-private.*.id}"]
  internal = true

  count = "${var.Counts["Master"] > 1 ? 1 : 0}"

  tags {
    Type = "internal"
    Name = "Training ${var.Training} - Internal Master LB"
    Training = "${var.Training}"
  }
}

resource "aws_lb_target_group" "internal-lb-tg1" {
  name     = "training-${var.Training}-internal-lb-tg1"
  port     = 8443
  protocol = "TCP"
  vpc_id   = "${aws_vpc.vpc.id}"

  count = "${aws_lb.internal-lb.count}"

  tags {
    Name = "Training ${var.Training} - Internal Master Traffic"
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

resource "aws_lb_listener" "internal-lb-listener1" {
  count = "${aws_lb.internal-lb.count}"

  load_balancer_arn = "${aws_lb.internal-lb.arn}"
  port              = "8443"
  protocol          = "TCP"

  default_action {
    target_group_arn = "${aws_lb_target_group.internal-lb-tg1.arn}"
    type             = "forward"
  }
}

resource "aws_lb_listener" "internal-lb-listener2" {
  count = "${aws_lb.internal-lb.count}"

  load_balancer_arn = "${aws_lb.internal-lb.arn}"
  port              = "443"
  protocol          = "TCP"

  default_action {
    target_group_arn = "${aws_lb_target_group.internal-lb-tg1.arn}"
    type             = "forward"
  }
}