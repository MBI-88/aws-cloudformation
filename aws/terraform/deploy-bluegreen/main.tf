resource "aws_security_group" "alb_sg" {
  name   = "ALBsg"
  vpc_id = var.vpc_id
  ingress = [
    {
      protocol    = "tcp"
      from_port   = 80
      to_port     = 80
      cidr_blocks = "0.0.0.0/0"
    },
    {
      protocol    = "tcp"
      from_port   = 8080
      to_port     = 8080
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  egress = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]

    }
  ]
}

resource "aws_lb_target_group" "lb_group_blue" {
  name        = "ALBBlueGroup"
  target_type = "ip"
  vpc_id      = var.vpc_id
  protocol    = "HTTP"
  port        = 80
  health_check {
    interval = 5
    path     = "/"
    port     = 80
    protocol = "HTTP"
    timeout  = 2
    matcher = 200
    unhealthy_threshold = 4
  }

  tags = {
    "Group" = "Blue"
  }

}

resource "aws_lb_target_group" "lb_group_green" {
  name        = "ALBGreenGroup"
  target_type = "ip"
  vpc_id      = var.vpc_id
  protocol    = "HTTP"
  port        = 80
  health_check {
    interval = 5
    path     = "/"
    port     = 80
    protocol = "HTTP"
    timeout  = 2
    matcher = 200
    unhealthy_threshold = 4
  }
  tags = {
    "Group" = "Green"
  }

}

resource "aws_lb" "load_balancer" {
  name               = "ALB"
  ip_address_type    = "ipv4"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [var.subnet_1, var.subnet_2]
  tags = {
    "Group" = "Balancer"
  }
}

resource "aws_lb_listener" "listener" {
  default_action {
    type = "forward"
    forward {
      target_group {
        arn    = aws_lb_target_group.lb_group_blue.arn
        weight = 1
      }
    }
  }
  load_balancer_arn = aws_lb.load_balancer.arn
  port              = 80
  protocol          = "HTTP"
}

resource "aws_lb_listener_rule" "listener_rules" {
  action {
    type = "forward"
    forward {
      target_group {
        arn = aws_lb_target_group.lb_group_blue.arn
      }
    }
  }
  condition {
    http_header {
      http_header_name = "User-Agent"
      values           = ["Mozilla"]
    }
  }
  listener_arn = aws_lb_listener.listener.arn
  priority     = 1
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ECSTaskExecutionRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = ""
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]

  })

}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_task_definition" "ecs_blue_task_definition" {
  family                   = "ecs-demo"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  container_definitions = jsonencode([
    {
      name      = "BlueEnv"
      image     = var.image
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ]
    }
  ])

}

resource "aws_ecs_task_definition" "ecs_green_task_definition" {
  family                   = "ecs-demo"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  container_definitions = jsonencode([
    {
      name      = "GreenEnv"
      image     = var.image
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ]
    }
  ])
}

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "ECScluster"
}

resource "aws_ecs_service" "ecs_service" {
  name        = "ECSservice"
  cluster     = aws_ecs_cluster.ecs_cluster.id
  launch_type = "FARGATE"
  depends_on  = [aws_iam_role.ecs_task_execution_role]
  network_configuration {
    subnets          = [var.subnet_1, var.subnet_2]
    assign_public_ip = "ENABLED"
    security_groups  = [aws_security_group.alb_sg.id]
  }
  platform_version = "1.4.0"
  task_definition  = aws_ecs_task_definition.ecs_blue_task_definition.arn
  load_balancer {
    container_name   = "BlueEnv"
    container_port   = 80
    target_group_arn = aws_lb_target_group.lb_group_blue.arn
  }

  deployment_controller {
    type = "CODE_DEPLOY"
  }
}

resource "aws_codedeploy_app" "ecs_app" {
  name             = "ecs-bluegreen-app"
  compute_platform = "ECS"
}

resource "aws_iam_role" "codedeploy_role" {
  name = "CodeDeployRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "codedeploy.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]

  })
}

resource "aws_iam_role_policy_attachment" "codedeploy_role_policy" {
  role       = aws_iam_role.codedeploy_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECS"
}

resource "aws_codedeploy_deployment_group" "ecs_deployment_group" {
  app_name               = aws_codedeploy_app.ecs_app.name
  deployment_group_name  = "ecs-bluegreen-dg"
  service_role_arn       = aws_iam_role.codedeploy_role.arn
  deployment_config_name = "CodeDeployDefault.ECSLinear10PercentEvery1Minutes"
  ecs_service {
    cluster_name = aws_ecs_cluster.ecs_cluster.name
    service_name = aws_ecs_service.ecs_service.name
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [aws_lb_listener.listener.arn]
      }
      target_group {
        name = aws_lb_target_group.lb_group_blue.name
      }
      target_group {
        name = aws_lb_target_group.lb_group_green.name
      }
    }
  }
}

