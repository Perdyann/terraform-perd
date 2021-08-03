#cliuser
provider "aws" {
    region = "ca-central-1"
    # will use default aws config and creds in env if not provided
    access_key = "<your_access_key_if_not_configured_in_env>"
    secret_key = "<your_secret_key_if_not_configured_in_env>"
}

# example object type variable - with model enforcement
variable "subnet_cidr_block" {
    description = "subnet cidr block"
    default = {"cidr": "10.0.10.0/24", "name": "terraform-dev-subnet"}
    type = object({
        name= string,
        cidr= string
    })
}

# basic string variable type example
variable "vpc_cidr_block" {
    description = "vpc cidr block"
    default = "10.0.0.0/16"
    type = string
}

variable "my_ip" {}

resource "aws_vpc" "development-vpc" {
    cidr_block = var.vpc_cidr_block
    tags = {
        Name: "terraform-dev-vpc"
    }
}

resource "aws_subnet" "development-subnet" {
    vpc_id     = aws_vpc.development-vpc.id
    cidr_block = var.subnet_cidr_block.cidr
    availability_zone = "ca-central-1a"
    tags = {
        Name: var.subnet_cidr_block.name
    }
}

# data "aws_vpc" "existing_vpc" {
#     default = true
# }

# resource "aws_subnet" "development-subnet-2" {
#     vpc_id     = data.aws_vpc.existing_vpc.id
#     cidr_block = "172.31.48.0/20"
#     tags = {
#         Name: "terraform-from-default"
#     }
# }

# output "dev-vpc-id" {
#     value = aws_vpc.development-vpc.id
# }

# output "dev-subnet-id" {
#     value = aws_subnet.development-subnet.id
# }

resource "aws_internet_gateway" "terraform-igw" {
    vpc_id = aws_vpc.development-vpc.id
    tags = {
        Name = "terraform-igw"
    }
}

# // try regular after
resource "aws_default_route_table" "terraform-main-rtb" {
    default_route_table_id = aws_vpc.development-vpc.default_route_table_id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.terraform-igw.id
    }
    tags = {
        Name = "terraform-main-rtb"
    }
}


resource "aws_security_group" "terraform-sec-grp" {
    vpc_id      = aws_vpc.development-vpc.id

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

output "aws_ami_id" {
    value = data.aws_ami.latest-amazon-linux-image.id
}

output "ec2_public_ip" {
    value = aws_instance.terraform-instance.public_ip
}

resource "aws_key_pair" "terraform-ssh-key" {
    key_name = "terraform-docker-server"
    public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_instance" "terraform-instance" {
  ami           = data.aws_ami.latest-amazon-linux-image.id
  instance_type = "t2.micro"
  subnet_id = aws_subnet.development-subnet.id
  vpc_security_group_ids = [aws_security_group.terraform-sec-grp.id]
  availability_zone = "ca-central-1a"

  associate_public_ip_address = true
  key_name = aws_key_pair.terraform-ssh-key.key_name

  user_data = file("entry-script.sh")

  tags = {
    Name = "terraform-instance-server"
  }
}