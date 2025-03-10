# Create an ECS Cluster
resource "aws_ecs_cluster" "c" {
  for_each = var.ecs

  name = each.key
}

# ECS Task definition (Define infrastructure and container images)
resource "aws_ecs_task_definition" "t" {
  for_each = var.ecs-fargate-tasks

  family                   = each.value.family
  network_mode             = each.value.network_mode
  requires_compatibilities = each.value.requires_compatibilities
  cpu                      = each.value.cpu
  memory                   = each.value.memory
  execution_role_arn       = aws_iam_role.roles[each.value.role_name].arn
  container_definitions = jsonencode([
    {
      name      = each.value.container_definitions.name
      image     = "${aws_ecr_repository.images[each.value.container_definitions.ecr_name].repository_url}:${each.value.container_definitions.tag}"
      memory    = each.value.container_definitions.memory
      essential = each.value.container_definitions.essential
      environment = [for k, v in each.value.container_definitions.environment : {
        name  = k
        value = v
      }]
      portMappings = each.value.container_definitions.containerPort != null ? [
        {
          containerPort = each.value.container_definitions.containerPort 
        }
      ] : []
    }
  ])
}

# ECS Service 
resource "aws_ecs_service" "s" {
  for_each = var.ecs-services

  name            = each.key
  cluster         = aws_ecs_cluster.c[each.value.ecs_cluster_name].id
  task_definition = aws_ecs_task_definition.t[each.value.task_name].arn
  launch_type     = each.value.launch_type
  desired_count   = each.value.desired_count
  network_configuration {
    subnets = [
      for subnet_name in each.value.network_configuration.subnet_names :
      aws_subnet.private_subnets[subnet_name].id
    ]

    assign_public_ip = each.value.network_configuration.assign_public_ip
    
    security_groups = [
      for sg_name in each.value.network_configuration.security_group_names :
      aws_security_group.sg[sg_name].id
    ]
  }
  dynamic "load_balancer" {
    for_each = each.value.load_balancer.target_group_name != null ? [each.value.load_balancer] : []
    content {
      target_group_arn = aws_lb_target_group.http[load_balancer.value.target_group_name].arn
      container_name   = load_balancer.value.container_name
      container_port   = load_balancer.value.container_port
    }
  }
}