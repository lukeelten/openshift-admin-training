
resource "aws_route53_record" "router-record" {
  zone_id = "${data.aws_route53_zone.existing-zone.zone_id}"
  name    = "*.apps.${var.Zone}"
  type = "CNAME"

  ttl = "300"
  records = ["${aws_instance.master-node.public_dns}"]
}

resource "aws_route53_record" "master-record" {
  zone_id = "${data.aws_route53_zone.existing-zone.zone_id}"
  name    = "master.${data.aws_route53_zone.existing-zone.name}"
  type = "CNAME"

  ttl = "300"
  records = ["${aws_instance.master-node.public_dns}"]
}
