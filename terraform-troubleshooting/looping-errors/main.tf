resource "aws_instance" "web_app" {
  for_each = aws_security_group.*.id

  instance_type = "t3.micro"

  ami                    = local.image.ami_id
  subnet_id              = local.network.subnet_id
  vpc_security_group_ids = [each.id]

  user_data = file("user-data.sh")

  tags = {
    Name = "${var.name}-justice"
  }
}

resource "aws_security_group" "sg_ping" {
  name   = "Allow Ping"
  vpc_id = local.network.vpc_id
}

resource "aws_security_group" "sg_8080" {
  name   = "Allow 8080"
  vpc_id = local.network.vpc_id
}

resource "aws_security_group_rule" "sg_ping" {
  type     = "ingress"
  protocol = "icmp"

  from_port = -1
  to_port   = -1

  security_group_id        = aws_security_group.sg_ping.id
  source_security_group_id = aws_security_group.sg_8080.id
}

resource "aws_security_group_rule" "sg_8080" {
  type     = "ingress"
  protocol = "tcp"

  from_port = 8080
  to_port   = 8080

  security_group_id        = aws_security_group.sg_8080.id
  source_security_group_id = aws_security_group.sg_ping.id
}
