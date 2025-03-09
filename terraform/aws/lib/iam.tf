resource "aws_iam_policy" "policies" {
  for_each    = var.iam-policies

  name        = each.key
  description = each.value.description

  policy = jsonencode({
    Version   = each.value.version
    Statement = each.value.statements
  })
}

resource "aws_iam_role" "roles" {
  for_each = var.iam-roles

  name = each.key

  assume_role_policy = jsonencode({
    Version = each.value.assume_role_policy.version
    Statement = [{
      Effect    = each.value.assume_role_policy.Effect
      Principal = each.value.assume_role_policy.Principal
      Action    = each.value.assume_role_policy.Action
    }]
  })
}


resource "aws_iam_role_policy_attachment" "attachments" {
  for_each = var.iam-attachments

  role       = aws_iam_role.roles[each.value.role_name].name
  policy_arn = aws_iam_policy.policies[each.value.policy_name].arn
}


