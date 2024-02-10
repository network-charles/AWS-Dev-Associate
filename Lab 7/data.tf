data "aws_iam_role" "ecsTaskExecutionRole" {
  name = "ecsTaskExecutionRole"
}

# define a service role to the assumed
data "aws_iam_policy_document" "ec2_ecs_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com", "ecs.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy" "AmazonSSMManagedInstanceCore" {
  name = "AmazonSSMManagedInstanceCore"
}

# This role grants the permission ecs:RegisterContainerInstance, which is used by the ECS Service Agent running in the EC2 Instance to register itself as a newly started Container Instance in the ECS Cluster. It is used along with the ec2 name being sdpecified in the /etc/ecs/ecs.config file of the instance.
data "aws_iam_policy" "AmazonEC2ContainerServiceforEC2Role" {
  name = "AmazonEC2ContainerServiceforEC2Role"
}

data "aws_iam_policy" "AmazonElasticFileSystemFullAccess" {
  name = "AmazonElasticFileSystemFullAccess"
}

data "aws_ami" "amazon" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["amazon"]
}

data "aws_instance" "eu_west_2a" {
  filter {
    name   = "tag:Name"
    values = ["asg"]
  }

  filter {
    name   = "availability-zone"
    values = ["eu-west-2a"]
  }

  filter {
    name   = "instance-state-name"
    values = ["running"]
  }

  depends_on = [aws_autoscaling_group.asg]
}

data "aws_instance" "eu_west_2b" {
  filter {
    name   = "tag:Name"
    values = ["asg"]
  }

  filter {
    name   = "availability-zone"
    values = ["eu-west-2b"]
  }

  filter {
    name   = "instance-state-name"
    values = ["running"]
  }

  depends_on = [aws_autoscaling_group.asg]
}

data "aws_efs_mount_target" "efs" {
  mount_target_id = aws_efs_mount_target.mount[0].id
}
