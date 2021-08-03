variable vpc_id {}
variable "subnet_cidr_block" {
    description = "subnet cidr block"
    default = {"cidr": "10.0.10.0/24", "name": "terraform-dev-subnet"}
    type = object({
        name= string,
        cidr= string
    })
}
variable default_route_table_id {}
variable availability_zone {
    default = "ca-central-1a"
}