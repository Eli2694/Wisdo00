resource "aws_ecr_repository" "images" {
  for_each = var.ecr

  name = each.key

  image_scanning_configuration {
    scan_on_push = each.value.scan_on_push
  }
}
