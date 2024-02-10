resource "aws_iam_role_policy_attachment" "ECS_SSM" {
  policy_arn = data.aws_iam_policy.AmazonSSMManagedInstanceCore.arn
  role       = data.aws_iam_role.ecsTaskExecutionRole.name
}

# Create an IAM role for the EC2 instance to allow AWS SSM access.
resource "aws_iam_role" "EC2_ECS_Role" {
  name               = "EC2-Role"
  assume_role_policy = data.aws_iam_policy_document.ec2_ecs_assume_role.json

  tags = {
    "Name" = "EC2_ECS_Role"
  }
}

resource "aws_iam_instance_profile" "ec2" {
  name = "ec2"
  role = aws_iam_role.EC2_ECS_Role.name

  tags = {
    "Name" = "ec2"
  }
}

resource "aws_iam_role_policy_attachment" "EC2_SSM" {
  policy_arn = data.aws_iam_policy.AmazonSSMManagedInstanceCore.arn
  role       = aws_iam_role.EC2_ECS_Role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerServiceforEC2Role" {
  policy_arn = data.aws_iam_policy.AmazonEC2ContainerServiceforEC2Role.arn
  role       = aws_iam_role.EC2_ECS_Role.name
}

resource "aws_iam_role_policy_attachment" "AmazonElasticFileSystemFullAccess" {
  policy_arn = data.aws_iam_policy.AmazonElasticFileSystemFullAccess.arn
  role       = aws_iam_role.EC2_ECS_Role.name
}

# Create a key_name for SSH 
resource "tls_private_key" "key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "key_pair" {
  key_name   = "myKey"
  public_key = tls_private_key.key.public_key_openssh

  provisioner "local-exec" { # Create "myKey.pem" to your computer!!
    command = <<-EOT
        echo '${tls_private_key.key.private_key_pem}' > ./myKey.pem
        
        # make myKey.pem readable
        chmod 400 myKey.pem
    EOT
  }
}

# add a security group 
resource "aws_security_group" "SG" {
  name        = "SG"
  description = "Allow all inbound traffic"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    description = "all"
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
