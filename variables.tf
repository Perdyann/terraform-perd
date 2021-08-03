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