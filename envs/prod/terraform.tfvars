aws_region = "ap-south-1"

vpc_name = "anant-tf-vpc"

vpc_cidr = "10.0.0.0/16"

az_list = [ "ap-south-1a", "ap-south-1b" ]

public_sub_cidrs = [ "10.0.1.0/24", "10.0.2.0/24" ]

private_sub_cidrs = [ "10.0.101.0/24", "10.0.102.0/24" ]

app_port = 8080

ami_id = "ami-0ced6a024bb18ff2e"    # OS

instance_type = "t3.micro"      # CPU & RAM

min_size = 2

desired_capacity = 4

max_size = 6

