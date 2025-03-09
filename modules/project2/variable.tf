variable "cidr_block" {
    description = "VPC CIDR Block"
    type = string
}
variable "subnet_cidr_block" {
    description = "Subnet CIDR Block"
    type = string
}
variable "instance_type" {
description = "Instance type of Ec2"
type = string
}
variable ami {
description = "ami of ec2"
type = string
}
