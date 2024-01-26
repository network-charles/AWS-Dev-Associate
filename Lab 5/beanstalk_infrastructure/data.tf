data "aws_sns_topic" "aws_ssm_parameter" {
  name = "All_Topics"
}

data "aws_iam_policy_document" "assume_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy" "AWSElasticBeanstalkWebTier" {
  name = "AWSElasticBeanstalkWebTier"
}