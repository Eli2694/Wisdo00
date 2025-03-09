resource "aws_eip" "nat_eip" {
  for_each  = var.nat-eip

  domain     = each.value.domain
  depends_on = [aws_internet_gateway.main_igw]

  tags = {
    Name = "${each.key}"
  }
}

resource "aws_nat_gateway" "nat_gw" {
  for_each  = var.nat-gw

  subnet_id     = aws_subnet.public_subnets[each.value.subnet_name].id
  allocation_id = aws_eip.nat_eip[each.value.nat_eip_name].id

  tags = {
    Name = "${each.key}"
  }
}
