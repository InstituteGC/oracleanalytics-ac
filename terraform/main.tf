data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-20231025"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "tls_private_key" "private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "${local.prefix}-key"
  public_key = tls_private_key.private_key.public_key_openssh
}

resource "aws_eip" "elastic_ip" {
  instance = aws_instance.instance.id

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_security_group" "allow_ssh_and_web" {
  name        = "${local.prefix}-allow_ssh_and_web"

  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  # Other known ports not opened:
  # * 9500 - WebLogic admin (at http://1.2.3.4:9500/console/)

  # http://1.2.3.4:9502/dv
  ingress {
    description      = "Oracle Analytics"
    from_port        = 9502
    to_port          = 9502
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_instance" "instance" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.xlarge"
  key_name      = aws_key_pair.generated_key.key_name

  vpc_security_group_ids = [aws_security_group.allow_ssh_and_web.id]

  tags = {
    Name = "${local.prefix}-instance"
  }

  root_block_device {
    volume_size = 70
  }
}

resource "local_file" "private_key" {
  sensitive_content = tls_private_key.private_key.private_key_pem
  filename          = "${path.module}/../ansible/.ssh/key.pem"
  file_permission   = "0600"
}

resource "local_file" "hosts_cfg" {
  content = templatefile("${path.module}/templates/hosts.tpl",
    {
      ip = aws_eip.elastic_ip.public_ip
    }
  )
  filename = "../ansible/inventory/hosts.cfg"
}
