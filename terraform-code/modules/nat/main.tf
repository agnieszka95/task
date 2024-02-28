resource "aws_eip" "nat_eip" {
  vpc = true
  tags = {
    Name = "NAT Gateway EIP"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = var.subnet_id

  tags = {
    Name = "Production NAT Gateway"
  }
}

# Route table association to direct traffic from a private subnet
resource "aws_route_table_association" "private_rt_assoc" {
  subnet_id      = var.private_subnet_id
  route_table_id = var.route_table_id  
}

# Route in the route table to direct traffic to the NAT Gateway
resource "aws_route" "nat_route" {
  route_table_id         = var.route_table_id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}
