resource "aws_vpc" "development-vpc" {
    cidr_block = var.vpc_cidr_block
    tags = {
        Name: "terraform-dev-vpc"
    }
}

data "aws_vpc" "existing_vpc" {
    default = true
}

module "subnet-mod" {
    source = "./modules/subnet"
    vpc_id = aws_vpc.development-vpc.id
    subnet_cidr_block = var.subnet_cidr_block
    default_route_table_id = aws_vpc.development-vpc.default_route_table_id
    availability_zone = "ca-central-1a"
}

module "webserver-mod" {
    source = "./modules/webserver"
    vpc_id = aws_vpc.development-vpc.id
    availability_zone = "ca-central-1a"
    my_ip = var.my_ip
    subnet_id = module.subnet-mod.development-subnet.id
}

# module "subnet2-mod" {
#     source = "./modules/subnet"
#     vpc_id = data.aws_vpc.existing_vpc.id
#     subnet_cidr_block = {"cidr": "172.31.48.0/20", "name": "terraform-from-default"}
#     default_route_table_id = aws_vpc.development-vpc.default_route_table_id
# }





# resource "aws_security_group" "terraform-sec-grp" {
#     vpc_id      = aws_vpc.development-vpc.id

#     ingress {
#         from_port = 22
#         to_port = 22
#         protocol = "tcp"
#         cidr_blocks = [var.my_ip]
#     }

#     ingress {
#         from_port = 8080
#         to_port = 8080
#         protocol = "tcp"
#         cidr_blocks = ["0.0.0.0/0"]
#     }

#     egress {
#         from_port = 0
#         to_port = 0
#         protocol = "-1"
#         cidr_blocks = ["0.0.0.0/0"]
#         prefix_list_ids = []
#     }

#     tags = {
#         Name = "terraform_sg"
#     }
# }

# data "aws_ami" "latest-amazon-linux-image" {
#     most_recent = true
#     owners = ["amazon"]
#     filter {
#         name = "name"
#         values = ["amzn2-ami-hvm-*-x86_64-gp2"]
#     }
#     filter {
#         name = "virtualization-type"
#         values = ["hvm"]
#     }
# }

# resource "aws_key_pair" "terraform-ssh-key" {
#     key_name = "terraform-docker-server"
#     public_key = file("~/.ssh/id_rsa.pub")
# }

# resource "aws_instance" "terraform-instance" {
#   ami           = data.aws_ami.latest-amazon-linux-image.id
#   instance_type = "t2.micro"
#   subnet_id = module.subnet-mod.development-subnet.id
#   vpc_security_group_ids = [aws_security_group.terraform-sec-grp.id]
#   availability_zone = "ca-central-1a"

#   associate_public_ip_address = true
#   key_name = aws_key_pair.terraform-ssh-key.key_name

#   user_data = file("entry-script.sh")

#     #   connection {
#     #     type = "ssh"
#     #     host = self.public_ip
#     #     user = "ec2-user"
#     #     private_key = file("~/.ssh/id_rsa")
#     #   }

#     #   provisioner "file" {
#     #     source = "entry-script.sh"
#     #     destination = "/home/ec2-user/entry-script.sh"
#     #   }

#     #   provisioner "remote-exec" {
#     #     script = file("entry-script.sh")
#     #     # inline = [
#     #     #     "mkdir fileabc"
#     #     #     "export ENV=dev"
#     #     # ]
#     #   }

#     #   provisioner "local-exec" {
#     #     command = "Successfully provisioned resources, established connection, copied file source, and executed command on new aws instance ${self.public_ip}"
#     #   }

#   tags = {
#     Name = "terraform-instance-server"
#   }
# }