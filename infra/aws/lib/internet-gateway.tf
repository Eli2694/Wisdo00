# Since we have to build public subnets, we need to provide access to the internet in the given VPC

resource "aws_internet_gateway" "gw" {
 for_each = var.internet-gateway

 vpc_id = aws_vpc.main[each.value.vpc_name].id

 tags = {
   Name = "${each.key}"
 }
}