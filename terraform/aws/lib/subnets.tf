resource "aws_subnet" "public_subnets" {
 for_each = var.public_subnets

 vpc_id            = aws_vpc.main[each.value.vpc_name].id
 cidr_block        = each.value.cidr_block
 availability_zone = each.value.availability_zone
 
 tags = {
   Name = "${each.key}"
 }
}
 
resource "aws_subnet" "private_subnets" {
 for_each = var.private_subnets

 vpc_id            = aws_vpc.main[each.value.vpc_name].id
 cidr_block        = each.value.cidr_block
 availability_zone = each.value.availability_zone
 
 tags = {
   Name = "${each.key}"
 }
}