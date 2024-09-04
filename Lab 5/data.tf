data "aws_sns_topic" "buildspec" {
  name = "All_Topics"
}

data "aws_iam_policy" "AWSCodeCommitFullAccess" {
  name = "AWSCodeCommitFullAccess"
}

data "aws_iam_policy_document" "codebuild_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy" "AdministratorAccess" {
  name = "AdministratorAccess"
}

# For CodePipeline
data "aws_iam_policy" "AWSCodeBuildAdminAccess" {
  name = "AWSCodeBuildAdminAccess"
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

data "aws_iam_policy" "AmazonS3FullAccess" {
  name = "AmazonS3FullAccess"
}
