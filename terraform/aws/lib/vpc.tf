# Since we are creating a VPC – a main Route table, and main Network ACL is also created. 
# The VPC is also associated with a pre-existing DHCP option set.
# The main route table is responsible for enabling the flow of traffic within the VPC. 

resource "aws_vpc" "main" {
 for_each = var.vpc

 cidr_block = each.value.cidr_block
 enable_dns_support = each.value.enable_dns_support
 enable_dns_hostnames = each.value.enable_dns_hostnames
 
 tags = {
   Name = "${each.key}"
 }
}