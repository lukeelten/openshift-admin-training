resource "aws_instance" "master-node" {

  ami             = "${data.aws_ami.centos.id}"
  instance_type   = "${var.Types["Master"]}"
  key_name        = "${aws_key_pair.public-key.key_name}"
  user_data       = "${file("assets/init.sh")}"

  vpc_security_group_ids = ["${aws_security_group.nodes-sg.id}", "${aws_security_group.master-sg.id}", "${aws_security_group.etcd-sg.id}", "${aws_security_group.infra-sg.id}"]
  subnet_id = "${aws_subnet.subnets-public.*.id[(count.index % aws_subnet.subnets-public.count)]}"

  count = "${var.Counts["Master"]}"

  root_block_device {
    volume_type = "gp2"
    volume_size = 80
  }

  lifecycle {
    create_before_destroy = true
  }

  tags {
    Type = "master"
    Name = "${var.ProjectName} - Master Node ${count.index + 1}"
    Project = "${var.ProjectName}"
    ProjectId = "${var.ProjectId}"
  }
}
