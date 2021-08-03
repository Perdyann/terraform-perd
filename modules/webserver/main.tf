resource "aws_security_group" "terraform-sec-grp" {
    vpc_id = var.vpc_id

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = [var.my_ip]
    }

    ingress {
        from_port = 8080
        to_port = 8080
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        prefix_list_ids = []
    }

    tags = {
        Name = "terraform_sg"
    }
}

data "aws_ami" "latest-amazon-linux-image" {
    most_recent = true
    owners = ["amazon"]
    filter {
        name = "name"
        values = ["amzn2-ami-hvm-*-x86_64-gp2"]
    }
    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }
}

resource "aws_key_pair" "terraform-ssh-key" {
    key_name = "terraform-docker-server"
    public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_instance" "terraform-instance" {
  ami = data.aws_ami.latest-amazon-linux-image.id
  instance_type = "t2.micro"
  subnet_id = var.subnet_id
  vpc_security_group_ids = [aws_security_group.terraform-sec-grp.id]
  availability_zone = "ca-central-1a"

  associate_public_ip_address = true
  key_name = aws_key_pair.terraform-ssh-key.key_name

  user_data = file("entry-script.sh")

  tags = {
    Name = "terraform-instance-server"
  }
}