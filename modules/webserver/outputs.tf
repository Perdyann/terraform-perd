output instance_public_ip {
    value = aws_instance.terraform-instance.public_ip
}

output aws_ami_id {
    value = data.aws_ami.latest-amazon-linux-image.id
}