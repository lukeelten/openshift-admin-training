
resource "aws_route53_record" "router-record" {
  zone_id = "${data.aws_route53_zone.existing-zone.zone_id}"
  name    = "*.apps.training${var.Training}.${data.aws_route53_zone.existing-zone.name}"
  type = "A"

  alias {
    name = "${aws_lb.external-lb.dns_name}"
    evaluate_target_health = false
    zone_id = "${aws_lb.external-lb.zone_id}"
  }
}

resource "aws_route53_record" "master-record" {
  zone_id = "${data.aws_route53_zone.existing-zone.zone_id}"
  name    = "master.training${var.Training}.${data.aws_route53_zone.existing-zone.name}"
  type = "A"

  alias {
    name = "${aws_lb.external-lb.dns_name}"
    evaluate_target_health = false
    zone_id = "${aws_lb.external-lb.zone_id}"
  }
}

resource "aws_route53_record" "internal-api-record" {
  zone_id = "${data.aws_route53_zone.existing-zone.zone_id}"
  name    = "internal-master.training${var.Training}.${data.aws_route53_zone.existing-zone.name}"
  type = "A"

  alias {
    name = "${aws_lb.internal-lb.dns_name}"
    evaluate_target_health = false
    zone_id = "${aws_lb.internal-lb.zone_id}"
  }
}

resource "aws_route53_record" "app-records" {
  zone_id = "${data.aws_route53_zone.existing-zone.zone_id}"
  name    = "app${count.index}.training${var.Training}.${data.aws_route53_zone.existing-zone.name}"
  type = "CNAME"

  count = "${var.Counts["App"]}"

  ttl = "300"
  records = ["${aws_instance.app-node.*.private_dns[count.index]}"]
}

resource "aws_route53_record" "master-nodes-records" {
  zone_id = "${data.aws_route53_zone.existing-zone.zone_id}"
  name    = "master${count.index}.training${var.Training}.${data.aws_route53_zone.existing-zone.name}"
  type = "CNAME"

  count = "${var.Counts["Master"]}"

  ttl = "300"
  records = ["${aws_instance.master-node.*.private_dns[count.index]}"]
}

resource "aws_route53_record" "infra-nodes-records" {
  zone_id = "${data.aws_route53_zone.existing-zone.zone_id}"
  name    = "infra${count.index}.training${var.Training}.${data.aws_route53_zone.existing-zone.name}"
  type = "CNAME"

  count = "${var.Counts["Infra"]}"

  ttl = "300"
  records = ["${aws_instance.infra-node.*.private_dns[count.index]}"]
}