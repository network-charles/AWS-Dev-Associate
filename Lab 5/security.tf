
resource "aws_iam_role" "codebuild" {
  name               = "codebuild"
  assume_role_policy = data.aws_iam_policy_document.codebuild_assume_role.json
}

resource "aws_iam_role_policy_attachment" "AdministratorAccess" {
  role   = aws_iam_role.codebuild.id
  policy_arn = data.aws_iam_policy.AdministratorAccess.arn
}

resource "aws_iam_role" "codepipeline" {
  name               = "codepipeline"
  assume_role_policy = data.aws_iam_policy_document.codepipeline_assume_role.json
}

resource "aws_iam_role_policy_attachment" "AWSCodePipelineFullAccess" {
  role   = aws_iam_role.codepipeline.id
  policy_arn = data.aws_iam_policy.AWSCodePipeline_FullAccess.arn
}

resource "aws_iam_role_policy_attachment" "AmazonS3FullAccess2" {
  role   = aws_iam_role.codepipeline.id
  policy_arn = data.aws_iam_policy.AmazonS3FullAccess.arn
}

resource "aws_iam_role_policy_attachment" "AWSCodeCommitFullAccess" {
  role   = aws_iam_role.codepipeline.id
  policy_arn = data.aws_iam_policy.AWSCodeCommitFullAccess.arn
}

resource "aws_iam_role_policy_attachment" "AWSCodeBuildAdminAccess" {
  role       = aws_iam_role.codepipeline.id
  policy_arn = data.aws_iam_policy.AWSCodeBuildAdminAccess.arn
}

