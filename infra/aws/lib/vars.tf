variable "vpc" {
    type = map(object({
      cidr_block = string
      enable_dns_support   = optional(bool, true)
      enable_dns_hostnames = optional(bool, true)
    }))
    default = {}
}

variable "public_subnets" {
  type = map(object({
    vpc_name = string
    cidr_block = string
    availability_zone = string
  }))
  default = {}
}

variable "private_subnets" {
  type = map(object({
    vpc_name = string
    cidr_block = string
    availability_zone = string
  }))
  default = {}
}

variable "internet-gateway" {
  type = map(object({
    vpc_name = string
  }))
  default = {}
}

variable "nat-eip" {
  type = map(object({
    domain = optional(string, "vpc") 
  }))
  default = {}
}

variable "nat-gw" {
  type = map(object({
    subnet_name = string
    nat_eip_name = string
  }))
  default = {}
}

variable "gt-route-tables" {
  type = map(object({
    vpc_name = string
    internet_gateway_name = string
    cidr_block = string
  }))
  default = {}
}

variable "nat-route-tables" {
  type = map(object({
    vpc_name = string
    nat_gateway_name = string
    cidr_block = string
  }))
  default = {}
}

variable "gt-route-tables-associations" {
  type = map(object({
    subnet_name = string
    route_table_name = string
  }))
  default = {}
}

variable "nat-route-tables-associations" {
  type = map(object({
    subnet_name = string
    route_table_name = string
  }))
  default = {}
}

variable "ecr" {
  type = map(object({
    scan_on_push = optional(bool, true)
  }))
  default = {}
}

variable "security-groups" {
  type = map(object({
    vpc_name    = string
    description = string
  }))
  default = {}
}

variable "security-groups-ingress" {
  type = map(object({
    vpc_name            = string
    security_group_name = string
    cidr_ipv4           = optional(list(string), null)
    from_port           = number
    ip_protocol         = string
    to_port             = number
    referenced_security_group_name = string
    prefix_list_id      = optional(list(string), null)
    use_cloudfront_ids  = optional(bool, false)
    use_reference_sg    = optional(bool, false)
  }))
  default = {}
}

variable "security-groups-egress" {
  type = map(object({
    security_group_name = string
    cidr_ipv4           = optional(list(string), null)
    ip_protocol         = string
    from_port           = number
    to_port             = number
  }))
  default = {}
}

variable "alb" {
  type = map(object({
    load_balancer_type  = optional(string, "application") 
    enable_http2        = optional(bool, true)
    internal            = optional(bool, true)
    security_group_name = list(string)
    subnet_name         = list(string)
  }))
  default = {}
}

variable "alb-target-groups-http" {
  type = map(object({
    name              = string
    port              = number
    protocol          = string
    protocol_version  = optional(string, "HTTP1") # Only applicable when protocol is HTTP or HTTPS.
    target_type       = string
    vpc_name          = string
    health_check = {
      protocol            = optional(string, "HTTP")
      path                = string
      matcher             = string
      interval            = optional(number, 30)
      timeout             = optional(number, 10)
      healthy_threshold   = optional(number, 3)
      unhealthy_threshold = optional(number, 3)
      }
  }))
  default = {}
}

variable "alb-listeners" {
  type = map(object({
    load_balancer_name = string
    port               = number
    protocol           = string
    ssl_policy         = optional(string, "ELBSecurityPolicy-TLS-1-2-2017-01")
    type               = optional(string, "forward") 
    target_group_name  = string
  }))
  default = {}
}

variable "ecs" {
  type = map(object({
    main-ecs = {
      # configuration, settings, service_connect_defaults 
    }
  }))
  default = {}
}

variable "ecs-fargate-tasks" {
  type = map(object({
    family                   = string
    network_mode             = optional(string, "awsvpc") 
    requires_compatibilities = optional(list(string), ["FARGATE"]) 
    cpu                      = number # Number of cpu units 1024 units = 1 vCPU
    memory                   = number # Amount (in MiB)
    role_name                = string
    container_definitions = {
      name          = string
      ecr_name      = string
      tag           = string
      memory        = number
      essential     = optional(bool, true)
      containerPort = optional(number, null)
      environment   = optional(map(string), {}) # collection of key-value pairs.
      }
  }))
  default = {}
}

variable "ecs-services" {
  type = map(object({
    ecs_cluster_name = string
    task_name = string
    desired_count   = number
    launch_type     = optional(string, "FARGATE")
    network_configuration = object({
      subnet_name = list(string)
      security_group_name = list(string)
      assign_public_ip = optional(bool, false)
    })
    load_balancer = object({
      target_group_name = string
      container_name   = string
      container_port   = number
    })
  }))
  default = {}
}


variable "iam-policies" {
  type = map(object({
     description = string
     version     = optional(string, "2012-10-17")
     statements  = list(object({
       Effect    = string
       Action    = list(string)
       Resource  = list(string)
     }))
  }))
  default = {}
}

variable "iam-roles" {
  type = map(object({
    assume_role_policy = object({
      version     = optional(string, "2012-10-17")
      Effect    = string
      Principal = map(list(string))
      Action    = string
    })
  }))
  default = {}
}

variable "iam-attachments" {
  type = any
}

