# https://hackernoon.com/manage-aws-vpc-as-infrastructure-as-code-with-terraform-55f2bdb3de2a
# https://nickcharlton.net/posts/terraform-aws-vpc.html

resource "aws_vpc" "vpc" {
  cidr_block = "${var.vpc_range}"

  enable_dns_hostnames = true

  tags {
    Owner       = "${var.user}"
    Name        = "VPC - ${var.cliente}"
  }
}

# Define the public subnets
resource "aws_subnet" "public-subnet" {
  count = "${length(var.pub_subnets_ranges)}"

  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "${var.pub_subnets_ranges[count.index]}"
  availability_zone = "${var.zones[count.index]}"
  depends_on = ["aws_vpc.vpc"]

  tags {
    Name = "Public Subnet ${count.index + 1} - ${var.cliente}"
  }
}

# Define the private subnets
resource "aws_subnet" "private-subnet" {
  count = "${length(var.priv_subnets_ranges)}"

  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "${var.priv_subnets_ranges[count.index]}"
  availability_zone = "${var.zones[count.index]}"
  depends_on = ["aws_vpc.vpc"]

  tags {
    Name = "Private Subnet ${count.index + 1} - ${var.cliente}"
  }
}

# Define the internet gateway
resource "aws_internet_gateway" "tf-igw" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "IGW - ${var.cliente}"
  }
}

# Define the route tables
resource "aws_route_table" "public-rt" {
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.tf-igw.id}"
  }

  tags {
    Name = "Public Route Table - ${var.cliente}"
  }
}

resource "aws_route_table" "private-rt" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "Private Route Table - ${var.cliente}"
  }
}

# Assign the route table to the Subnets
resource "aws_route_table_association" "public-rt" {
  count = "${length(var.pub_subnets_ranges)}"

  subnet_id      = "${element(aws_subnet.public-subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.public-rt.id}"
}

resource "aws_route_table_association" "private-rt" {
  count = "${length(var.priv_subnets_ranges)}"

  subnet_id      = "${element(aws_subnet.private-subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.private-rt.id}"
}

# Define the security group for public subnets
resource "aws_security_group" "sg_externo" {
  name = "sg_externo_${var.cliente}"
  description = "Allow incoming HTTP connections & SSH access"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 30000
    to_port = 32767
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    # IP de casa (09/06/2018)
    cidr_blocks =  ["187.20.141.252/32"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    # prefix_list_ids = ["pl-12c4e678"]
  }

  vpc_id="${aws_vpc.vpc.id}"

  tags {
    Name = "SG Externo - ${var.cliente}"
  }
}

# Define the security group for private subnet
resource "aws_security_group" "sg_interno"{
  name = "sg_interno_${var.cliente}"
  description = "Allow traffic from public subnet"

  ingress {
    from_port = 0
    to_port = 65535
    protocol = "tcp"
    cidr_blocks = ["${var.vpc_range}"]
  }

  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["${var.vpc_range}"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
    # prefix_list_ids = ["pl-12c4e678"]
  }

  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "SG Interno - ${var.cliente}"
  }
}
