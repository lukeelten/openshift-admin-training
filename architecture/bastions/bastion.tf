resource "aws_instance" "bastion" {
  depends_on             = ["aws_internet_gateway.igw"]

  ami                    = "${data.aws_ami.centos.id}"
  instance_type          = "${var.Type}"
  key_name               = "heinlein-training-${var.Training}"

  subnet_id              = "${aws_subnet.subnets-public.*.id[0]}"

  user_data              = "${file("assets/bastion.sh")}"
  vpc_security_group_ids = ["${aws_security_group.bastion-sg.id}"]
  ebs_optimized = true

  root_block_device {
    volume_type = "gp2"
    volume_size = 8
  }

  tags = {
    Type = "bastion"
    Name = "Training ${var.Training} - Bastion"
    Training = "${var.Training}"
  }
}

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