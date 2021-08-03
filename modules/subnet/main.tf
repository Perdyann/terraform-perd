
resource "aws_subnet" "development-subnet" {
    vpc_id     = var.vpc_id
    cidr_block = var.subnet_cidr_block.cidr
    availability_zone = var.availability_zone
    tags = {
        Name: var.subnet_cidr_block.name
    }
}

resource "aws_internet_gateway" "terraform-igw" {
    vpc_id = var.vpc_id
    tags = {
        Name = "terraform-igw"
    }
}

# // try regular after
resource "aws_default_route_table" "terraform-main-rtb" {
    # default_route_table_id = aws_vpc.development-vpc.default_route_table_id
    default_route_table_id = var.default_route_table_id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.terraform-igw.id
    }
    tags = {
        Name = "terraform-main-rtb"
    }
}