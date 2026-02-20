resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true // resources automatically can resolve(convert) dns names to ip
  enable_dns_hostnames = true // to assign dns hostnames to EC2 & ALB

  tags = {
    Name = var.vpc_name
  }
}

// to connect above vpc to the internet
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.vpc_name}-igw"
  }
}

resource "aws_subnet" "public_sub" {
  count = length(var.public_sub_cidrs)
  vpc_id = aws_vpc.this.id
  availability_zone = var.az_list[count.index]  // count.index starts from 0
  cidr_block = var.public_sub_cidrs[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-${count.index + 1}"
  }
}
resource "aws_subnet" "private_sub" {
    count = length(var.private_sub_cidrs)
    vpc_id = aws_vpc.this.id
    availability_zone = var.az_list[count.index]
    cidr_block = var.private_sub_cidrs[count.index]
    tags = {
        Name = "private-subnet-${count.index +1}"
    }
}

resource "aws_eip" "nat" {
    domain = "vpc"
    tags = {
      Name = "${var.vpc_name}-nat-eip"
    }
}
resource "aws_nat_gateway" "this" {
  subnet_id = aws_subnet.public_sub[0].id
  allocation_id = aws_eip.nat.id
  depends_on = [ aws_internet_gateway.this ]
  tags = {
    Name = "${var.vpc_name}-nat"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"        // allows inbound + outbound
    gateway_id = aws_internet_gateway.this.id
  }
  tags = {
    Name = "${var.vpc_name}-public-rt"
  }
}
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"        // allows outbound + only inbound which are responses for outbound
    nat_gateway_id = aws_nat_gateway.this.id
  }
  tags = {
    Name = "${var.vpc_name}-private-rt"
  }
}
// route table associations to respective subnets
resource "aws_route_table_association" "public" {
    count = length(var.public_sub_cidrs)
    route_table_id = aws_route_table.public_rt.id
    subnet_id = aws_subnet.public_sub[count.index].id
}
resource "aws_route_table_association" "private" {
  count = length(var.private_sub_cidrs)
  route_table_id = aws_route_table.private_rt.id
  subnet_id = aws_subnet.private_sub[count.index].id
}