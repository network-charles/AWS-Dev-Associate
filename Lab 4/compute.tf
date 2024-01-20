resource "aws_ecs_cluster" "ecs" {
  name = var.ecs_cluster_name

  tags = {
    "Name" = "ecs"
  }
}

resource "aws_ecs_task_definition" "nginx" {
  family       = "fargate"
  network_mode = "awsvpc"
  # pull container image using fargate
  execution_role_arn = data.aws_iam_role.ecsTaskExecutionRole.arn
  # call other AWS Service role
  task_role_arn = aws_iam_role.ecsTaskRole.arn
  requires_compatibilities = [ "FARGATE" ]
  cpu = "1024"
  memory = "2048"

  container_definitions = jsonencode([
    {
        name      = var.container_name
        image     = "nginx:alpine"
        essential = true
        linuxParameters = {"initProcessEnabled": true}
        portMappings = [
            {
                containerPort = 80
                hostPort      = 80
                protocol      = "tcp"
            }
        ]
    }
  ])

  tags = {
    "Name" = "nginx"
  }

  depends_on = [ aws_ecs_cluster.ecs ]
}


resource "aws_ecs_service" "service" {
  name    = "service"
  cluster = aws_ecs_cluster.ecs.arn
  desired_count = 1
  task_definition = aws_ecs_task_definition.nginx.arn
  enable_execute_command = true
  launch_type = "FARGATE"
  enable_ecs_managed_tags = true
  wait_for_steady_state = true

  network_configuration {
    subnets = [ aws_subnet.public1.id, aws_subnet.public2.id ]
    security_groups = [ aws_security_group.SG.id ]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs_awsvpc_mode.arn
    container_name   = var.container_name
    container_port   = 80
  }
}

resource "null_resource" "grab_task_id" {

  provisioner "local-exec" {
    command = "echo 'Executing command...'; task_id=($(aws ecs list-tasks --cluster ecs | grep -o 'ecs/[^\"]*' | cut -d'/' -f2)); echo $task_id > task_id.txt"
  }

  depends_on = [aws_ecs_service.service]
}

resource "aws_lb" "alb" {
  name               = "alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.SG.id]
  subnets            = [aws_subnet.public1.id, aws_subnet.public2.id]

  enable_deletion_protection = true

  tags = {
    Environment = "alb"
  }
}

resource "aws_lb_target_group" "ecs_awsvpc_mode" {
  name        = "ecs-awsvpc-mode"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.ecs_cluster.id

  tags = {
    "Name" = "ecs_awsvpc_mode"
  }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_awsvpc_mode.arn
  }
}