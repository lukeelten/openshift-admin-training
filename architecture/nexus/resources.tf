provider "aws" {
  region = "eu-central-1"
  version = "1.60"
}

data "aws_availability_zones" "frankfurt" {}

data "aws_route53_zone" "existing-zone" {
  name = "cc-openshift.de"
  private_zone = false
}


data "aws_ami" "centos" {
  most_recent = true

  filter {
    name   = "name"
    values = ["CentOS Linux 7 x86_64 HVM EBS ENA *"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["679593333241"] # CentOS official
}

resource "aws_vpc" "vpc" {
  cidr_block                       = "10.20.0.0/16"
  enable_dns_hostnames             = true

  tags {
    Name = "Nexus - VPC"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "Nexus - Internet Gateway"
  }
}

resource "aws_subnet" "subnet-public" {
  vpc_id            = "${aws_vpc.vpc.id}"
  availability_zone = "${data.aws_availability_zones.frankfurt.names[0]}"

  cidr_block              = "${cidrsubnet(aws_vpc.vpc.cidr_block, 8, 1)}"
  map_public_ip_on_launch = true

  tags {
    Name = "Nexus - Public Subnet"
  }
}

resource "aws_route_table" "public-rt" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }

  tags {
    Name = "Nexus - Public Route Table"
  }
}

resource "aws_route_table_association" "public-to-rt" {
  subnet_id      = "${aws_subnet.subnet-public.id}"
  route_table_id = "${aws_route_table.public-rt.id}"
}

resource "aws_security_group" "nexus-sg" {
  description = "Nexus Example"
  name        = "nexus"
  vpc_id      = "${aws_vpc.vpc.id}"

  ingress = [
    {
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
    },
    {
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
    },
    {
      from_port        = 443
      to_port          = 443
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
    },
    {
      from_port        = 8080
      to_port          = 8081
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
    },
    {
      from_port        = 389
      to_port          = 389
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
    },
    {
      from_port        = 636
      to_port          = 636
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
    },
    {
      from_port        = 5000
      to_port          = 5010
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
    Name = "Nexus SG"
  }
}

resource "aws_instance" "nexus" {
  depends_on      = ["aws_internet_gateway.igw"]

  ami             = "${data.aws_ami.centos.id}"
  instance_type   = "m5a.xlarge"
  key_name        = "heinlein-training-0"
  user_data       = "${file("init.sh")}"

  vpc_security_group_ids = ["${aws_security_group.nexus-sg.id}"]
  subnet_id = "${aws_subnet.subnet-public.id}"

  root_block_device {
    volume_type = "gp2"
    volume_size = 50
  }

  lifecycle {
    create_before_destroy = true
  }

  tags {
    Name = "Nexus Example"
    Type = "nexus"
    Training = "0"
  }
}

resource "aws_route53_record" "nexus-record" {
  zone_id = "${data.aws_route53_zone.existing-zone.zone_id}"
  name    = "nexus.${data.aws_route53_zone.existing-zone.name}"
  type = "A"

  ttl = "300"
  records = ["${aws_instance.nexus.public_ip}"]
}

resource "aws_route53_record" "ldap-record" {
  zone_id = "${data.aws_route53_zone.existing-zone.zone_id}"
  name    = "ldap.${data.aws_route53_zone.existing-zone.name}"
  type = "A"

  ttl = "300"
  records = ["${aws_instance.nexus.public_ip}"]
}

resource "aws_route53_record" "sso-record" {
  zone_id = "${data.aws_route53_zone.existing-zone.zone_id}"
  name    = "sso.${data.aws_route53_zone.existing-zone.name}"
  type = "A"

  ttl = "300"
  records = ["${aws_instance.nexus.public_ip}"]
}