data "aws_iam_policy_document" "codedeploy_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codedeploy.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

# For EC2, ASG, SNS, Cloudwatch, ELB
data "aws_iam_policy" "AWSCodeDeployRolePolicy" {
  name = "AWSCodeDeployRole"
}

data "aws_sns_topic" "codedeploy" {
  name = "All_Topics"
}

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy" "AmazonEC2RoleforAWSCodeDeploy" {
  name = "AmazonEC2RoleforAWSCodeDeploy"
}

data "aws_iam_policy" "AmazonSSMManagedInstanceCore" {
  name = "AmazonSSMManagedInstanceCore"
}

data "aws_iam_policy_document" "codepipeline_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy" "AWSCodePipeline_FullAccess" {
  name = "AWSCodePipeline_FullAccess"
}

data "aws_iam_policy" "AWSCodeCommitFullAccess" {
  name = "AWSCodeCommitFullAccess"
}

data "aws_iam_policy" "AmazonS3FullAccess" {
  name = "AmazonS3FullAccess"
}

data "aws_iam_policy" "AWSCodeDeployFullAccess" {
  name = "AWSCodeDeployFullAccess"
}
