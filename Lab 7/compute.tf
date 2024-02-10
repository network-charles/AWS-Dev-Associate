data "template_file" "AmazonEFSUtils" {
  template = file("AmazonEFSUtils.sh")

  vars = {
    ecs_cluster_name = aws_ecs_cluster.ecs.name
  }
}

# Create a launch template for ASG 
resource "aws_launch_template" "lt" {
  image_id               = data.aws_ami.amazon.id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.SG.id]
  user_data              = base64encode(data.template_file.AmazonEFSUtils.rendered)
  key_name               = aws_key_pair.key_pair.key_name

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 30
      volume_type = "gp2"
    }
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2.name
  }
}

# Create an ASG with a launch template and tag.
resource "aws_autoscaling_group" "asg" {
  name                = "asg"
  desired_capacity    = 2
  max_size            = 2
  min_size            = 1
  vpc_zone_identifier = [aws_subnet.my_subnet_1.id, aws_subnet.my_subnet_2.id]

  launch_template {
    id      = aws_launch_template.lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "asg"
    propagate_at_launch = true
  }

  depends_on = [aws_ecs_cluster.ecs]
}

resource "aws_autoscaling_lifecycle_hook" "ecs-managed-draining-termination-hook" {
  name                   = "ecs-managed-draining-termination-hook"
  autoscaling_group_name = aws_autoscaling_group.asg.name
  default_result         = "ABANDON"
  heartbeat_timeout      = 30
  lifecycle_transition   = "autoscaling:EC2_INSTANCE_TERMINATING"
}

# Define an ECS cluster with a specified name and tag.
resource "aws_ecs_cluster" "ecs" {
  name = var.ecs_cluster_name

  tags = {
    "Name" = "ecs"
  }
}

resource "aws_ecs_capacity_provider" "ec2" {
  name = "ec2"

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.asg.arn

    managed_scaling {
      maximum_scaling_step_size = 1000
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 2
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "cluster" {
  cluster_name       = aws_ecs_cluster.ecs.name
  capacity_providers = [aws_ecs_capacity_provider.ec2.name]
}

# Define an ECS task definition with a Fargate launch type, specifying container details.
resource "aws_ecs_task_definition" "nginx" {
  family             = "nginx"
  network_mode       = "awsvpc"
  execution_role_arn = data.aws_iam_role.ecsTaskExecutionRole.arn
  task_role_arn      = data.aws_iam_role.ecsTaskExecutionRole.arn

  volume {
    name = var.volume
    efs_volume_configuration {
      file_system_id = aws_efs_file_system.efs.id
    }
  }

  # Define container details, including the image, port mappings, and essential status.
  container_definitions = jsonencode([
    {
      name            = var.container_name
      image           = "nginx:alpine"
      essential       = true
      cpu             = 256
      memory          = 512
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ]
      volumes = [
        {
          name = var.volume
          efsVolumeConfiguration = {
            fileSystemId = "${aws_efs_file_system.efs.id}"
          }
        }
      ]
      mountPoints = [
        {
          containerPath = "/usr/share/nginx/html"
          sourceVolume  = var.volume
        }
      ]
    }
  ])

  tags = {
    "Name" = "nginx"
  }

  depends_on = [aws_ecs_cluster.ecs]
}

# Define an ECS service to run tasks using the specified task definition.
resource "aws_ecs_service" "service" {
  name                    = "service"
  cluster                 = aws_ecs_cluster.ecs.arn
  desired_count           = 2
  task_definition         = aws_ecs_task_definition.nginx.arn
  enable_execute_command  = true
  enable_ecs_managed_tags = true
  force_new_deployment    = true
  wait_for_steady_state   = true

  # Configure network settings, including subnets, security groups, and public IP assignment.
  network_configuration {
    subnets         = [aws_subnet.my_subnet_1.id, aws_subnet.my_subnet_2.id]
    security_groups = [aws_security_group.SG.id]
  }

  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.ec2.name
    weight            = 100
  }

  # Spread tasks evenly accross all Availability Zones for High Availability
  ordered_placement_strategy {
    type  = "spread"
    field = "attribute:ecs.availability-zone"
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs_tg.arn
    container_name   = var.container_name
    container_port   = 80
  }

  depends_on = [aws_autoscaling_group.asg]
}

# Define an EFS file system with a creation token and tag.
resource "aws_efs_file_system" "efs" {
  creation_token = "efs"

  tags = {
    Name = "efs"
  }
}

# Create EFS mount targets associated with the EFS file system in different subnets.
resource "aws_efs_mount_target" "mount" {
  count          = 2
  file_system_id = aws_efs_file_system.efs.id
  # 1/2=0.5 odd, 2/2=1 even
  # if count.index is divided by 2 and the remainder is even, 
  # assign instance to aws_subnet.my_subnet_1.id, 
  # else aws_subnet.my_subnet_2.id
  subnet_id       = count.index % 2 == 0 ? aws_subnet.my_subnet_1.id : aws_subnet.my_subnet_2.id
  security_groups = [aws_security_group.SG.id]
}

resource "aws_lb" "ecs_alb" {
  name               = "ecs-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.SG.id]
  subnets            = [aws_subnet.my_subnet_1.id, aws_subnet.my_subnet_2.id]

  tags = {
    Name = "ecs-alb"
  }
}

resource "aws_lb_listener" "ecs_alb_listener" {
  load_balancer_arn = aws_lb.ecs_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_tg.arn
  }
}

resource "aws_lb_target_group" "ecs_tg" {
  name        = "ecs-target-group"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.my_vpc.id

  health_check {
    path = "/"
  }
}
