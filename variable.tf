# variable for vpc cidr range
variable "vpc-cidr" {
    type = string
    default = "10.0.0.0/16"    
}

# give project a name
variable "project" {
    type = string
    default = "apache"
}

# specify a launch template ami
variable "ami" {
    type = string
    default = "ami-0dab9ecf8f21f9ff3"
}
