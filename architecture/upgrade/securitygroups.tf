resource "aws_security_group" "bastion-sg" {
  description = "Training ${var.Training} Security Group for Bastion server"
  name        = "training-${var.Training}-bastion-sg"
  vpc_id      = "${aws_vpc.vpc.id}"

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    from_port        = "-1"
    to_port          = "-1"
    protocol         = "icmp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Training ${var.Training} - Bastion SG"
    Training = "${var.Training}"
  }
}

resource "aws_security_group" "master-sg" {
  description = "Training ${var.Training} Security Group for Master Nodes"
  name        = "training-${var.Training}-master-sg"
  vpc_id      = "${aws_vpc.vpc.id}"

  ingress {
    from_port        = 8443
    to_port          = 8443
    protocol         = "tcp"
    // Should be restricted to master load balancer, but network lbs does not have security groups
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Training ${var.Training} - Master Nodes SG"
    Training = "${var.Training}"
  }
}

resource "aws_security_group" "infra-sg" {
  description = "Training ${var.Training} Security Group for Infrastructure Nodes"
  name        = "training-${var.Training}-infra-sg"
  vpc_id      = "${aws_vpc.vpc.id}"

  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    // Should be restricted to router lb
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    // Should be restricted to router lb
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Training ${var.Training} - Infrastructure Nodes SG"
    Training = "${var.Training}"
  }
}

resource "aws_security_group" "nodes-sg" {
  description = "Training ${var.Training} Security Group for Nodes"
  name        = "training-${var.Training}-nodes-sg"
  vpc_id      = "${aws_vpc.vpc.id}"

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    from_port        = 1
    to_port          = 65535
    protocol         = "tcp"
    self             = true
  }

  ingress {
    from_port        = 1
    to_port          = 65535
    protocol         = "udp"
    self             = true
  }

  ingress {
    from_port        = "-1"
    to_port          = "-1"
    protocol         = "icmp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Training ${var.Training} - Nodes SG"
    Training = "${var.Training}"
  }
}
