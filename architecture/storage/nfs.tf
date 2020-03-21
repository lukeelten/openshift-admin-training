resource "aws_instance" "nfs" {
  ami             = data.aws_ami.centos.id
  instance_type   = var.Types["NFS"]
  key_name        = "heinlein-training-${var.Training}"
  user_data       = file("assets/nfs.sh")

  vpc_security_group_ids = ["${aws_security_group.nodes-sg.id}"]
  subnet_id = aws_subnet.subnets-public.*.id[0]
  ebs_optimized = true

  root_block_device {
    volume_type = "gp2"
    volume_size = 50
  }

  ebs_block_device {
    delete_on_termination = true
    volume_type ="gp2"
    volume_size = 250
    device_name = "/dev/sdb"
  }


  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Type = "nfs"
    Name = "Training ${var.Training} - NFS"
    Training = var.Training
  }
}

resource "aws_route53_record" "nfs-record" {
  zone_id = data.aws_route53_zone.existing-zone.zone_id
  name    = "nfs.training${var.Training}.${data.aws_route53_zone.existing-zone.name}"
  type = "CNAME"

  ttl = "300"
  records = [aws_instance.nfs.private_dns]
}