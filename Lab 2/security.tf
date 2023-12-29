resource "aws_iam_role" "codebuild" {
  name               = "codebuild"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_policy" "policy" {
  name        = "test-policy"
  description = "A test policy"
  policy      = data.aws_iam_policy_document.ecr_codecommit.json
}

resource "aws_iam_policy_attachment" "test-attach" {
  name       = "test-attachment"
  roles      = [aws_iam_role.codebuild.name]
  policy_arn = aws_iam_policy.policy.arn
}
