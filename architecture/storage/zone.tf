
resource "aws_route53_record" "router-record" {
  zone_id = "${data.aws_route53_zone.existing-zone.zone_id}"
  name    = "*.apps.training${var.Training}.${var.Zone}"
  type = "A"

  ttl = "300"
  records = ["${aws_instance.master-node.public_ip}"]
}

resource "aws_route53_record" "master-record1" {
  zone_id = "${data.aws_route53_zone.existing-zone.zone_id}"
  name    = "master0.training${var.Training}.${data.aws_route53_zone.existing-zone.name}"
  type = "CNAME"

  ttl = "300"
  records = ["${aws_instance.master-node.public_dns}"]
}

resource "aws_route53_record" "master-record2" {
  zone_id = "${data.aws_route53_zone.existing-zone.zone_id}"
  name    = "master.training${var.Training}.${data.aws_route53_zone.existing-zone.name}"
  type = "CNAME"

  ttl = "300"
  records = ["${aws_instance.master-node.public_dns}"]
}

resource "aws_route53_record" "internal-api-record" {
  zone_id = "${data.aws_route53_zone.existing-zone.zone_id}"
  name    = "internal-master.training${var.Training}.${data.aws_route53_zone.existing-zone.name}"
  type = "CNAME"

  ttl = "300"
  records = ["${aws_instance.master-node.public_dns}"]
}

resource "aws_route53_record" "app-records" {
  zone_id = "${data.aws_route53_zone.existing-zone.zone_id}"
  name    = "app${count.index}.training${var.Training}.${data.aws_route53_zone.existing-zone.name}"
  type = "A"

  count = "${var.Counts["App"]}"

  ttl = "300"
  records = ["${aws_instance.app-node.*.public_ip[count.index]}"]
}