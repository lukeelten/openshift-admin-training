resource "aws_route53_record" "bastion-record" {
  zone_id = "${data.aws_route53_zone.existing-zone.zone_id}"
  name    = "bastion.training${var.Training}.${data.aws_route53_zone.existing-zone.name}"
  type = "A"

  ttl = "300"
  records = ["${aws_instance.bastion.public_ip}"]
}
