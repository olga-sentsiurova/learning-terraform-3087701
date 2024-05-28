data "aws_ami" "app_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["bitnami-tomcat-*-x86_64-hvm-ebs-nami"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["979382823631"] # Bitnami
}

data "aws_vpc" "default" {
  default = true
}

resource "aws_instance" "blog" {
  ami           = data.aws_ami.app_ami.id
  instance_type = var.instance_type

  vpc_security_group_ids = [module.blog_sq.security_group_id]

  tags = {
    Name = "HelloWorld"
  }
}

module "blog_sq" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.2"
  name = "blog_new"

  vpc_id = data.aws_vpc.default.id
  ingress_rules = ["http-80-tcp", "https-443-tcp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]
  egress_rules = ["all-all"]
  egress_cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_security_group" "blog" {
  name        = "blog"
  description = "Allow HTTP and HTTPS in, allow everything out."

  vpc_id = data.aws_vpc.default.id
}

resource "aws_security_group_rule" "blog_http_in" {
  from_port   = 80
  protocol    = "tcp"
  to_port     = 80
  type        = "ingress"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.blog.id
}

resource "aws_security_group_rule" "blog_https_in" {
  from_port   = 443
  protocol    = "tcp"
  to_port     = 443
  type        = "ingress"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.blog.id
}

resource "aws_security_group_rule" "blog_everything_out" {
  from_port   = 0
  protocol    = "-1"
  to_port     = 0
  type        = "egress"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.blog.id
}