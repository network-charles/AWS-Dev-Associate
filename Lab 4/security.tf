resource "aws_security_group" "SG" {
  name        = "SG"
  description = "Allow all inbound traffic"
  vpc_id      = aws_vpc.ecs_cluster.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SG"
  }
}

resource "aws_iam_role" "ecsTaskRole" {
  name               = "ecsTaskRole"
  assume_role_policy = data.aws_iam_role.ecsTaskExecutionRole.assume_role_policy

  tags = {
    Name = "ecsTaskRole"
  }
}

resource "aws_iam_policy_attachment" "AmazonSSMManagedInstanceCore" {
  name       = "AmazonSSMManagedInstanceCore"
  roles      = [aws_iam_role.ecsTaskRole.name]
  policy_arn = data.aws_iam_policy.AmazonSSMManagedInstanceCore.arn
}

resource "aws_iam_role_policy_attachment" "AmazonS3FullAccess" {
  role   = aws_iam_role.ecsTaskRole.name
  policy_arn = data.aws_iam_policy.AmazonS3FullAccess.arn
}