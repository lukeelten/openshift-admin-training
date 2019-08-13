
resource "aws_lb" "internal-lb" {
  depends_on      = ["aws_internet_gateway.igw"]
  name = "training-${var.Training}-internal-lb"
  load_balancer_type = "network"

  subnets = ["${aws_subnet.subnets-private.*.id}"]
  internal = true

  tags = {
    Type = "internal"
    Name = "Training ${var.Training} - Internal Master LB"
    Training = "${var.Training}"
  }
}

resource "aws_lb_target_group" "internal-lb-master" {
  name     = "training-${var.Training}-internal-lb-master"
  port     = 8443
  protocol = "TCP"
  vpc_id   = "${aws_vpc.vpc.id}"

  tags = {
    Name = "Training ${var.Training} - Internal Master Traffic"
    Training = "${var.Training}"
  }

  health_check {
    protocol = "TCP"
    interval = 10
    healthy_threshold = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "internal-lb-listener" {
  load_balancer_arn = "${aws_lb.internal-lb.arn}"
  port              = "8443"
  protocol          = "TCP"

  default_action {
    target_group_arn = "${aws_lb_target_group.internal-lb-master.arn}"
    type             = "forward"
  }
}
