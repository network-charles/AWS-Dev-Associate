
resource "aws_iam_role" "codedeploy" {
  name               = "codedeploy-role"
  assume_role_policy = data.aws_iam_policy_document.codedeploy_assume_role.json
}

resource "aws_iam_role_policy_attachment" "AWSCodeDeployRole" {
  policy_arn = data.aws_iam_policy.AWSCodeDeployRolePolicy.arn
  role       = aws_iam_role.codedeploy.name
}

resource "aws_iam_role" "EC2InstanceRole" {
  name               = "EC2InstanceRole"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

resource "aws_iam_role_policy_attachment" "AmazonSSMManagedInstanceCore" {
  policy_arn = data.aws_iam_policy.AmazonSSMManagedInstanceCore.arn
  role       = aws_iam_role.EC2InstanceRole.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2RoleforAWSCodeDeploy" {
  policy_arn = data.aws_iam_policy.AmazonEC2RoleforAWSCodeDeploy.arn
  role       = aws_iam_role.EC2InstanceRole.name
}

resource "aws_iam_instance_profile" "EC2" {
  name = "EC2"
  role = aws_iam_role.EC2InstanceRole.name
}

resource "aws_iam_role" "codepipeline" {
  name               = "codepipeline-role"
  assume_role_policy = data.aws_iam_policy_document.codepipeline_assume_role.json
}

resource "aws_iam_role_policy_attachment" "AWSCodePipeline_FullAccess" {
  role   = aws_iam_role.codepipeline.id
  policy_arn = data.aws_iam_policy.AWSCodePipeline_FullAccess.arn
}

resource "aws_iam_role_policy_attachment" "AWSCodeCommitFullAccess" {
  role   = aws_iam_role.codepipeline.id
  policy_arn = data.aws_iam_policy.AWSCodeCommitFullAccess.arn
}

resource "aws_iam_role_policy_attachment" "AmazonS3FullAccess" {
  role   = aws_iam_role.codepipeline.id
  policy_arn = data.aws_iam_policy.AmazonS3FullAccess.arn
}

resource "aws_iam_role_policy_attachment" "AWSCodeDeployFullAccess" {
  role   = aws_iam_role.codepipeline.id
  policy_arn = data.aws_iam_policy.AWSCodeDeployFullAccess.arn
}

resource "aws_security_group" "SG" {
  vpc_id      = aws_vpc.VPC.id
  description = "SG"

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
    "Name" = "SG"
  }
}