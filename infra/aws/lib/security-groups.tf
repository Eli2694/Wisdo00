# The weight of a Amazon CloudFront managed prefix list is 55. Here's how the this affects your Amazon VPC quotas:
# Security groups – The default quota is 60 rules, leaving room for only 5 additional rules in a security group. 
# You can request a quota increase for this quota from AWS support.

data "aws_ec2_managed_prefix_list" "cloudfront" {
  name = "com.amazonaws.global.cloudfront.origin-facing"
}

resource "aws_security_group" "sg" {
  for_each = var.security-groups

  name        = each.key
  description = each.value.description
  vpc_id      = aws_vpc.main[each.value.vpc_name].id

  tags = {
    Name = "${each.key}"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ingress" {
  for_each = var.security-groups-ingress

  security_group_id = aws_security_group.sg[each.value.security_group_name].id
  cidr_ipv4         = each.value.cidr_ipv4
  from_port         = each.value.from_port
  ip_protocol       = each.value.ip_protocol
  to_port           = each.value.to_port
  prefix_list_id    = each.value.use_cloudfront_ids ? data.aws_ec2_managed_prefix_list.cloudfront.id : each.value.prefix_list_id
  referenced_security_group_id = each.value.use_reference_sg ? aws_security_group.sg[each.value.referenced_security_group_name].id : null
}

resource "aws_vpc_security_group_egress_rule" "egress" {
  for_each = var.security-groups-egress

  security_group_id = aws_security_group.sg[each.value.security_group_name].id
  cidr_ipv4         = each.value.cidr_ipv4
  ip_protocol       = each.value.ip_protocol
  from_port         = each.value.from_port
  to_port           = each.value.to_port
}

