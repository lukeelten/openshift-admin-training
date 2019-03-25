resource "aws_security_group" "bastion-sg" {
  description = "Training ${var.Training} Security Group for Bastion server"
  name        = "training-${var.Training}-bastion-sg"
  vpc_id      = "${aws_vpc.vpc.id}"

  ingress = [
    {
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
    },
    {
      from_port        = "-1"
      to_port          = "-1"
      protocol         = "icmp"
      cidr_blocks      = ["0.0.0.0/0"]
    }
  ]

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags {
    Name = "Training ${var.Training} - Bastion SG"
    Training = "${var.Training}"
  }
}

resource "aws_security_group" "internal-lb-sg" {
  description = "Training ${var.Training} Security Group for Internal Master Load Balancer"
  name        = "training-${var.Training}-internal-lb-sg"
  vpc_id      = "${aws_vpc.vpc.id}"

  ingress = [
    {
      from_port        = 8443
      to_port          = 8443
      protocol         = "tcp"
      security_groups  = ["${aws_security_group.nodes-sg.id}"]
    }
  ]

  egress {
    from_port        = 8443
    to_port          = 8443
    protocol         = "tcp"
    security_groups  = ["${aws_security_group.nodes-sg.id}"]
  }

  tags {
    Name = "Training ${var.Training} - Internal Load Balancer SG"
    Training = "${var.Training}"
  }
}

resource "aws_security_group" "master-sg" {
  description = "Training ${var.Training} Security Group for Master Nodes"
  name        = "training-${var.Training}-master-sg"
  vpc_id      = "${aws_vpc.vpc.id}"

  ingress = [
    {
      from_port        = 8053
      to_port          = 8053
      protocol         = "tcp"
      security_groups  = ["${aws_security_group.nodes-sg.id}"]
    },
    {
      from_port        = 8053
      to_port          = 8053
      protocol         = "udp"
      security_groups  = ["${aws_security_group.nodes-sg.id}"]
    },
    {
      from_port        = 8443
      to_port          = 8443
      protocol         = "tcp"
      // Should be restricted to master load balancer, but network lbs does not have security groups
      cidr_blocks      = ["0.0.0.0/0"]
    },
    {
      // Seems useless, but is for future use
      from_port        = 8443
      to_port          = 8443
      protocol         = "tcp"
      security_groups  = ["${aws_security_group.internal-lb-sg.id}", "${aws_security_group.nodes-sg.id}"]
    },
    {
      // Seems useless, but is for future use
      from_port        = 8444
      to_port          = 8444
      protocol         = "tcp"
      security_groups  = ["${aws_security_group.internal-lb-sg.id}", "${aws_security_group.nodes-sg.id}"]
    }
  ]

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags {
    Name = "Training ${var.Training} - Master Nodes SG"
    Training = "${var.Training}"
  }
}

resource "aws_security_group" "etcd-sg" {
  description = "Training ${var.Training} Security Group for ETCD"
  name        = "training-${var.Training}-etcd-sg"
  vpc_id      = "${aws_vpc.vpc.id}"

  ingress = [
    {
      from_port        = 2379
      to_port          = 2379
      protocol         = "tcp"
      security_groups  = ["${aws_security_group.nodes-sg.id}"]
    },
    {
      from_port        = 2380
      to_port          = 2380
      protocol         = "tcp"
      self             = true
    }
  ]

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags {
    Name = "Training ${var.Training} - ETCD SG"
    Training = "${var.Training}"
  }
}

resource "aws_security_group" "infra-sg" {
  description = "Training ${var.Training} Security Group for Infrastructure Nodes"
  name        = "training-${var.Training}-infra-sg"
  vpc_id      = "${aws_vpc.vpc.id}"

  ingress = [
    {
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      // Should be restricted to router lb
      cidr_blocks      = ["0.0.0.0/0"]
    },
    {
      from_port        = 443
      to_port          = 443
      protocol         = "tcp"
      // Should be restricted to router lb
      cidr_blocks      = ["0.0.0.0/0"]
    }
  ]

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags {
    Name = "Training ${var.Training} - Infrastructure Nodes SG"
    Project = "Training ${var.Training}"
    ProjectId = "training-${var.Training}"
  }
}

resource "aws_security_group" "nodes-sg" {
  description = "Training ${var.Training} Security Group for Nodes"
  name        = "training-${var.Training}-nodes-sg"
  vpc_id      = "${aws_vpc.vpc.id}"

  ingress = [
    {
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      security_groups  = ["${aws_security_group.bastion-sg.id}"]
    },
    {
      from_port        = 10250
      to_port          = 10250
      protocol         = "tcp"
      self             = true
    },
    {
      from_port        = 10256
      to_port          = 10256
      protocol         = "tcp"
      self             = true
    },
    {
      from_port        = 4789
      to_port          = 4789
      protocol         = "udp"
      self             = true
    },
    {
      from_port        = 53
      to_port          = 53
      protocol         = "udp"
      self             = true
    },
    {
      from_port        = 53
      to_port          = 53
      protocol         = "tcp"
      self             = true
    },
    {
      // Elastic Search
      from_port        = 9300
      to_port          = 9300
      protocol         = "tcp"
      self             = true
    },
    {
      // Elastic Search
      from_port        = 9200
      to_port          = 9200
      protocol         = "tcp"
      self             = true
    },
    {
      // Fluentd
      from_port        = 9880
      to_port          = 9880
      protocol         = "tcp"
      self             = true
    },
    {
      // Fluentd
      from_port        = 24224
      to_port          = 24224
      protocol         = "tcp"
      self             = true
    },
  ]

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags {
    Name = "Training ${var.Training} - Nodes SG"
    Training = "${var.Training}"
  }
}
