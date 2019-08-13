
resource "aws_lb" "router-lb" {
  depends_on      = ["aws_internet_gateway.igw"]
  name = "training-${var.Training}-router-lb"
  load_balancer_type = "network"

  subnets = ["${aws_subnet.subnets-public.*.id}"]

  tags = {
    Type = "infra"
    Name = "Training ${var.Training} - Router Load Balancer"
    Training = "${var.Training}"
  }
}

resource "aws_lb_listener" "router-lb-listener1" {
  load_balancer_arn = "${aws_lb.router-lb.arn}"
  port              = "80"
  protocol          = "TCP"

  default_action {
    target_group_arn = "${aws_lb_target_group.router-lb-tg1.arn}"
    type             = "forward"
  }
}

resource "aws_lb_listener" "router-lb-listener2" {
  load_balancer_arn = "${aws_lb.router-lb.arn}"
  port              = "443"
  protocol          = "TCP"

  default_action {
    target_group_arn = "${aws_lb_target_group.router-lb-tg2.arn}"
    type             = "forward"
  }
}

resource "aws_lb_target_group" "router-lb-tg1" {
  name     = "training-${var.Training}-router-lb-tg1"
  port     = 80
  protocol = "TCP"
  vpc_id   = "${aws_vpc.vpc.id}"

  tags = {
    Name = "Training ${var.Training} - Traffic Routing HTTP"
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

resource "aws_lb_target_group" "router-lb-tg2" {
  name     = "training-${var.Training}-router-lb-tg2"
  port     = 443
  protocol = "TCP"
  vpc_id   = "${aws_vpc.vpc.id}"

  tags = {
    Name = "Training ${var.Training} - Traffic Routing HTTPS"
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
