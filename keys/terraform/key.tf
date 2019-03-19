resource "aws_key_pair" "public-key" {
    key_name   = "heinlein-training-${count.index}"
    public_key = "${file("../")}"
}