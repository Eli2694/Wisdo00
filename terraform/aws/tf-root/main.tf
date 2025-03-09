module "main" {
  source = "../lib"

  vpc = {
    main = {
        cidr_block = "10.0.0.0/16"
    }
  }

  public_subnets = {
    subnet01-public = {
        vpc_name = "main"
        cidr_block = "10.0.1.0/24"
        availability_zone = "${var.PROD_AWS_REGION}a"
    }
    subnet02-public = {
        vpc_name = "main"
        cidr_block = "10.0.2.0/24"
        availability_zone = "${var.PROD_AWS_REGION}b"
    }
    subnet03-public = {
        vpc_name = "main"
        cidr_block = "10.0.3.0/24"
        availability_zone = "${var.PROD_AWS_REGION}c"
    }
  }

  private_subnets = { 
    subnet01-private = {
        vpc_name = "main"
        cidr_block = "10.0.4.0/24"
        availability_zone = "${var.PROD_AWS_REGION}a"
    }
    subnet02-private = {
        vpc_name = "main"
        cidr_block = "10.0.5.0/24"
        availability_zone = "${var.PROD_AWS_REGION}b"
    }
    subnet03-private = {
        vpc_name = "main"
        cidr_block = "10.0.6.0/24"
        availability_zone = "${var.PROD_AWS_REGION}c"
    }
  }

  internet-gateway = {
    main-ig = {
        vpc_name = "main"
    }
  }

  nat-eip = {
    subnet01-public-eip = {
    }
    subnet02-public-eip = { 
    }
    subnet03-public-eip = { 
    }
  }

  nat-gw = {
    nat-gw01 = {
      subnet_name = "subnet01-public"
      nat_eip_name = "subnet01-public-eip"
    }
    nat-gw02 = {
      subnet_name = "subnet02-public"
      nat_eip_name = "subnet02-public-eip"
    }
    nat-gw03 = {
      subnet_name = "subnet03-public"
      nat_eip_name = "subnet03-public-eip"
    }
  }

  gt-route-tables = {
    ig-rt = {
      vpc_name = "main"
      internet_gateway_name = "main-ig"
      cidr_block = "0.0.0.0/0"
    }
  }

  nat-route-tables = {
    nat-gw01-rt = {
      vpc_name = "main"
      cidr_block = "0.0.0.0/0"
      nat_gateway_name = "nat-gw01"
    }
    nat-gw02-rt = {
      vpc_name = "main"
      cidr_block = "0.0.0.0/0"
      nat_gateway_name = "nat-gw02"  
    }
    nat-gw03-rt = {
      vpc_name = "main"
      cidr_block = "0.0.0.0/0"
      nat_gateway_name = "nat-gw03"
    }
  }

  gt-route-tables-associations = {
    ig-asso01 = {
      subnet_name = "subnet01-public"
      route_table_name = "ig-rt"  
    }
    ig-asso02 = {
      subnet_name = "subnet02-public"
      route_table_name = "ig-rt"  
    }
    ig-asso03 = {
      subnet_name = "subnet03-public"
      route_table_name = "ig-rt"  
    }
  }

  # Private subnet in AZ a → NAT GW in AZ a, etc.
  nat-route-tables-associations = {
    nat_asso01 = {
      subnet_name = "subnet01-private"
      route_table_name = "nat-gw01-rt" 
    }
    nat_asso02 = {
      subnet_name = "subnet02-private"
      route_table_name = "nat-gw02-rt" 
    }
    nat_asso03 = {
      subnet_name = "subnet03-private"
      route_table_name = "nat-gw03-rt" 
    }
  }

  security-groups = {
    alb-private-sg = {
      vpc_name = "main"
      description = "Application Load Balancer Security Group"
    }
    nextjs-tasks-sg = {
      vpc_name = "main"
      description = "Next.Js ECS Tasks Security Group"    
    }
    backend-a-grpc-sg = {
      vpc_name = "main"
      description = "Backend A Tasks Security Group"    
    }
    backend-b-sg = {
      vpc_name = "main"
      description = "Backend B Tasks Security Group"    
    }
    
  }

  security-groups-ingress= {
    # ALB
    alb-ingress-rule01 = { # Only CloudFront VPC origin allowed.
      vpc_name            = "main"
      security_group_name = "alb-private-sg"
      from_port           = 443
      ip_protocol         = "tcp"
      to_port             = 443
      use_cloudfront_ids  = true
    }
    alb-ingress-rule02 = { # Allow gRPC (50051) from Next.js ECS tasks"
      vpc_name            = "main"
      security_group_name = "alb-private-sg"
      from_port           = 50051
      ip_protocol         = "tcp"
      to_port             = 50051
      use_reference_sg    = true
      # Using a direct SG-to-SG reference (security_groups) ensures traffic is allowed only from the intended AWS resources
      referenced_security_group_name = "nextjs-tasks-sg" 
    }
    # Next.js ECS Task Security Group
    nextjs-ingress-rule01 = { # Allow HTTP from ALB
      vpc_name            = "main"
      security_group_name = "nextjs-tasks-sg"
      from_port           = 3000
      ip_protocol         = "tcp"
      to_port             = 3000
      use_reference_sg    = true
      referenced_security_group_name = "alb-private-sg"
    }
    # Backend (gRPC) ECS Task Security Group
    backend-a-ingress-rule01 = { # Allow gRPC (50051) from ALB
      vpc_name            = "main"
      security_group_name = "backend-a-grpc-sg"
      from_port           = 50051
      ip_protocol         = "tcp"
      to_port             = 50051
      use_reference_sg    = true
      referenced_security_group_name = "alb-private-sg"
    }

  }

  security-groups-egress= {
    alb-egress-rule01 = {
      security_group_name = "alb-private-sg"
      cidr_ipv4           = [ "0.0.0.0/0" ]
      ip_protocol         = "-1" # semantically equivalent to all ports
      from_port           = 0
      to_port             = 0    
    }
    nextjs-egress-rule01 = {
      security_group_name = "nextjs-tasks-sg"
      cidr_ipv4           = [ "0.0.0.0/0" ]
      ip_protocol         = "-1" # semantically equivalent to all ports
      from_port           = 0
      to_port             = 0    
    }
    backend-a-egress-rule01 = {
      security_group_name = "backend-a-grpc-sg"
      cidr_ipv4           = [ "0.0.0.0/0" ]
      ip_protocol         = "-1" # semantically equivalent to all ports
      from_port           = 0
      to_port             = 0    
    }
    backend-b-egress-rule01 = {
      security_group_name = "backend-b-sg"
      cidr_ipv4           = [ "0.0.0.0/0" ]
      ip_protocol         = "-1" # semantically equivalent to all ports
      from_port           = 0
      to_port             = 0    
    }
  }

  ecr = {
    wisdo-ecr = {
      scan_on_push = true
    }
  }

  alb = {
    main-alb = {
      load_balancer_type   = "application"
      enable_http2         = true
      internal             = true
      security_group_name  = "alb-private-sg"
      subnet_name          = "subnet01-private"
    }
  }

  alb-target-groups-http = {
    grpc-backend-tg = {
      port             = 50051
      protocol          = "HTTP"
      protocol_version = "GRPC"
      target_type      = "ip"
      vpc_name = "main"
      health_check = {
        protocol            = "HTTP"
        path                = "/AWS.ALB/healthcheck"
        matcher             = "12" # gRPC success code
      }
    }
    nextjs-tg = {
      port             = 3000  
      protocol          = "HTTP"
      protocol_version = "GRPC"
      target_type      = "ip"
      vpc_name = "main"
      health_check = {
        protocol            = "HTTP"
        path                = "/"
        matcher             = "200" # gRPC success code
      }
    }
  }

  alb-listeners = {
    alb-https = {
      load_balancer_name = "main-alb"
      port              = 443
      protocol          = "HTTPS"
      ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
      type              = "forward"
      target_group_name = "nextjs-tg"
    }
    # Next.js ECS task sends gRPC requests directly to the ALB's internal DNS (alb-name.region.elb.amazonaws.com:50051).
    grpc-https = {
      load_balancer_name = "main-alb"
      port              = 50051
      protocol          = "HTTP" # HTTP with GRPC support
      ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
      type              = "forward"
      target_group_name = "grpc-backend-tg"
    }
  }

  ecs = {
    wisdo-ecs = {

    }
  }

  ecs-fargate-tasks = {
    nextjs-task = {
      family                   = "nextjs-service"
      network_mode             = "awsvpc"
      requires_compatibilities = ["FARGATE"]
      cpu                      = 256 # Number of cpu units 1024 units = 1 vCPU
      memory                   = 512 # Amount (in MiB)
      role_name                = "nextjs-ecs-task"
      container_definitions = {
        name          = "nextjs-container"
        image         = "<your-nextjs-image>"
        memory        = 512
        essential     = true
        containerPort = 3000
      }
    }
    backend-grpc-task = {
      family                   = "backend-grpc-service"
      cpu                      = 512 # Number of cpu units 1024 units = 1 vCPU
      memory                   = 1024 # Amount (in MiB)
      role_name                = "backend-a-ecs-task"
      container_definitions = {
        name          = "grpc-container"
        image         = "<your-grpc-image>"
        memory        = 1024
        containerPort = 50051
      }
    }
    backend-sqs-task = {
      family                   = "backend-sqs-service"
      cpu                      = 512 # Number of cpu units 1024 units = 1 vCPU
      memory                   = 1024 # Amount (in MiB)
      role_name                = "backend-b-ecs-task"
      container_definitions = {
        name          = "sqs-service"
        image         = "<your-sqs-image>"
        memory        = 1024
        environment = {
          "QUEUE_URL" = "aws_sqs_queue.app_queue.id",
        #   "REGION" = "us-east-1"
        }
      }
    }
  }

  ecs-services = {
    grpc-backend-service= {
      ecs_cluster_name = "wisdo-ecs"
      task_name = "backend-grpc-task"
      desired_count   = 3
      launch_type     = "FARGATE"
      network_configuration = {
        subnet_name = ["subnet01-private", "subnet02-private", "subnet03-private"]
        security_group_name = ["backend-a-grpc-sg"]
        assign_public_ip = false
      }
      load_balancer = {
        target_group_name = "grpc-backend-tg"
        container_name   = "grpc-container"
        container_port   = 50051
      }
    }
    nextjs-service = {
      ecs_cluster_name = "wisdo-ecs" 
      task_name = "nextjs-task"
      desired_count   = 3
      launch_type     = "FARGATE" 
      network_configuration = {
        subnet_name = ["subnet01-private", "subnet02-private", "subnet03-private"]
        security_group_name = ["nextjs-tasks-sg"]
        assign_public_ip = false
      }
      load_balancer = {
        target_group_name = "nextjs-tg"
        container_name   = "nextjs-container"
        container_port   = 3000
      } 
    }
    backend-b-service = {
      ecs_cluster_name = "wisdo-ecs" 
      task_name = "sqs-task"
      desired_count   = 3
      launch_type     = "FARGATE" 
      network_configuration = {
        subnet_name = ["subnet01-private", "subnet02-private", "subnet03-private"]
        security_group_name = ["backend-b-sg"]
        assign_public_ip = false
      }
      load_balancer = {
        target_group_name = null
        container_name   = "sqs-container"
        container_port   = null
      } 
    }
  }

  iam-policies = {
    ecr_and_sqs = {
      description = "Allows ECS tasks to pull images from ECR and access SQS."
      statements = [
        {
          Effect = "Allow"
          Action = [
            "ecr:GetAuthorizationToken",
            "ecr:BatchCheckLayerAvailability",
            "ecr:GetDownloadUrlForLayer",
            "ecr:BatchGetImage",
            "ecr:DescribeRepositories",
            "ecr:ListImages"
          ]
          Resource = ["*"]
        },
        {
          Effect = "Allow"
          Action = [
            "sqs:SendMessage",
            "sqs:ReceiveMessage",
            "sqs:DeleteMessage",
            "sqs:GetQueueAttributes"
          ]
          Resource = ["arn:aws:sqs:<region>:<account-id>:<queue-name>"]
        }
      ]
    },
    ecr_only = {
      description = "Allows ECS tasks to pull images from ECR only."
      statements = [
        {
          Effect = "Allow"
          Action = [
            "ecr:GetAuthorizationToken",
            "ecr:BatchCheckLayerAvailability",
            "ecr:GetDownloadUrlForLayer",
            "ecr:BatchGetImage",
            "ecr:DescribeRepositories",
            "ecr:ListImages"
          ]
          Resource = ["*"] # Using Resource = ["*"] for ECR actions is common because ECR authorization tokens don't support resource-level permissions well. (It's considered safe practice.)
        }
      ]
    }
  }

  iam-roles = {
    backend-a-ecs-task = {
      assume_role_policy = {
        Effect = "Allow"
        Principal = {
          Service = ["ecs-tasks.amazonaws.com"]
        }
        Action = "sts:AssumeRole"
      }
    }
    backend-b-ecs-task = {
      assume_role_policy = {
        Effect = "Allow"
        Principal = {
          Service = ["ecs-tasks.amazonaws.com"]
        }
        Action = "sts:AssumeRole"
      }
    }
    nextjs-ecs-task = {
      assume_role_policy = {
        Effect = "Allow"
        Principal = {
          Service = ["ecs-tasks.amazonaws.com"]
        }
        Action = "sts:AssumeRole"
      }
    }
  }

  iam-attachments = {
    ecr-and-sqs = {
      role_name = "backend-b-ecs-task"
      policy_name = "ecr_and_sqs" 
    }
    ecr-only = {
      role_name = "backend-a-ecs-task"
      policy_name = "ecr_only"
    }
    ecr-only02 = {
      role_name = "nextjs-ecs-task"
      policy_name = "ecr_and_sqs"
    }
  }

  providers = {
    aws = aws.PROD
  }

}

