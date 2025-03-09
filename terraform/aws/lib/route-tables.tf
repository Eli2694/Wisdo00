# We already know that when a VPC is created, a main route table is created as well. 
# The main route table is responsible for enabling the flow of traffic within the VPC. 
# The subnets are associated implicitly

# To make the subnets named “Public” public, we have to create routes using IGW which will enable the traffic from the Internet to access these subnets.

# As a best practice, we create a second route table and associate it with the same VPC. 
# Note that we have also specified the route to the internet (0.0.0.0/0) using our IGW.

resource "aws_route_table" "gt_rt" {
 for_each = var.gt-route-tables

 vpc_id = aws_vpc.main[each.value.vpc_name].id
 
 route {
   cidr_block = each.value.cidr_block
   gateway_id = aws_internet_gateway.gw[each.value.internet_gateway_name].id
 }
 
 tags = {
   Name = "${each.key}"
 }
}

resource "aws_route_table" "nat_rt" {
 for_each = var.nat-route-tables

 vpc_id = aws_vpc.main[each.value.vpc_name].id
 
 route {
   cidr_block = each.value.cidr_block
   nat_gateway_id = aws_nat_gateway.nat_gw[each.value.nat_gateway_name].id
 }
 
 tags = {
   Name = "${each.key}"
 }
}

# We have to explicitly associate all the public subnets with the second route table to enable internet access on them. 
# Add the Terraform configuration resource block below to do the same.

resource "aws_route_table_association" "gt_public_subnet_asso" {
 for_each = var.gt-route-tables-associations

 subnet_id      = aws_subnet.public_subnets[each.value.subnet_name].id
 route_table_id = aws_route_table.gt_rt[each.value.route_table_name].id
}

resource "aws_route_table_association" "nat_private_subnet_asso" {
 for_each = var.nat-route-tables-associations

 subnet_id      = aws_subnet.private_subnets[each.value.subnet_name].id
 route_table_id = aws_route_table.nat_rt[each.value.route_table_name].id
}