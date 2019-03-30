
resource "aws_route53_record" "router-record" {
  zone_id = "${data.aws_route53_zone.existing-zone.zone_id}"
  name    = "*.apps.training${var.Training}.${var.Zone}"
  type = "A"

  ttl = "300"
  records = ["${aws_instance.master-node.public_ip}"]
}

resource "aws_route53_record" "master-record" {
  zone_id = "${data.aws_route53_zone.existing-zone.zone_id}"
  name    = "master.training${var.Training}.${data.aws_route53_zone.existing-zone.name}"
  type = "A"

  ttl = "300"
  records = ["${aws_instance.master-node.public_ip}"]
}

resource "aws_route53_record" "bastion-record" {
  zone_id = "${data.aws_route53_zone.existing-zone.zone_id}"
  name    = "bastion.training${var.Training}.${data.aws_route53_zone.existing-zone.name}"
  type = "A"

  ttl = "300"
  records = ["${aws_instance.bastion.public_ip}"]
}

resource "aws_route53_record" "app-records" {
  zone_id = "${data.aws_route53_zone.existing-zone.zone_id}"
  name    = "app${count.index}.training${var.Training}.${data.aws_route53_zone.existing-zone.name}"
  type = "A"

  count = "${var.Counts["App"]}"

  ttl = "300"
  records = ["${aws_instance.app-node.*.public_ip[count.index]}"]
}

resource "aws_route53_record" "gluster-records" {
  zone_id = "${data.aws_route53_zone.existing-zone.zone_id}"
  name    = "gluster${count.index}.training${var.Training}.${data.aws_route53_zone.existing-zone.name}"
  type = "A"

  count = "${var.Counts["App"]}"

  ttl = "300"
  records = ["${aws_instance.app-node.*.private_ip[count.index]}"]
}