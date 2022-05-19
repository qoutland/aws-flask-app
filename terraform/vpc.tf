data "aws_region" "current" {}

# VPC
resource "aws_vpc" "vpc" {
  cidr_block           = "10.24.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = merge(local.tags, {
    Name = "${var.name}-vpc"
  })
}

# Subnets
resource "aws_subnet" "public_subnet" {
  count                   = var.subnet_num
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.24.${count.index}.0/24"
  availability_zone       = "${data.aws_region.current.name}${var.availability_zones[count.index]}"
  map_public_ip_on_launch = true
  tags = merge(local.tags, {
    Name = "${var.name}-public-subnet0${count.index}"
  })
}

resource "aws_subnet" "private_subnet" {
  count                   = var.subnet_num
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.24.${count.index + 2}.0/24"
  availability_zone       = "${data.aws_region.current.name}${var.availability_zones[count.index]}"
  map_public_ip_on_launch = false
  tags = merge(local.tags, {
    Name = "${var.name}-priv-subnet0${count.index}"
  })
}

# Internet Gateway
resource "aws_internet_gateway" "ig" {
  vpc_id = aws_vpc.vpc.id
  tags   = local.tags
}

# Nat Gateway
resource "aws_eip" "eip" {
  vpc = true
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public_subnet[0].id
  tags = merge(local.tags, {
    Name = "${var.name}-nat-gateway"
  })

  depends_on = [aws_internet_gateway.ig]
}

# Route tables
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.vpc.id
  tags = merge(local.tags, {
    Name = "${var.name}-private-rt"
  })
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id
  tags = merge(local.tags, {
    Name = "${var.name}-public-rt"
  })
}

resource "aws_route_table_association" "public_rta" {
  count          = var.subnet_num
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "private_rta" {
  count          = var.subnet_num
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route" "public_ig" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ig.id
}

resource "aws_route" "private_nat" {
  route_table_id         = aws_route_table.private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}