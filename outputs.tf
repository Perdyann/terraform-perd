
output "dev-vpc-id" {
    value = aws_vpc.development-vpc.id
}

output "dev-subnet-id" {
    value = module.subnet-mod.development-subnet.id
}

output "aws_ami_id" {
    value = module.webserver-mod.aws_ami_id
}

output "ec2_public_ip" {
    value = module.webserver-mod.instance_public_ip
}