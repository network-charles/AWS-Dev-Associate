resource "aws_iam_role" "aws-elasticbeanstalk-ec2-role" {
  name               = "aws-elasticbeanstalk-ec2-role"
  assume_role_policy = data.aws_iam_policy_document.assume_policy.json

  tags = {
    Name = "aws-elasticbeanstalk-ec2-role"
  }
}

resource "aws_iam_role_policy_attachment" "AWSElasticBeanstalkWebTier" {
  role       = aws_iam_role.aws-elasticbeanstalk-ec2-role.name
  policy_arn = data.aws_iam_policy.AWSElasticBeanstalkWebTier.arn
}

resource "aws_iam_instance_profile" "elasticbeanstalk_instance_profile" {
  name = "elasticbeanstalk_instance_profile"
  role = aws_iam_role.aws-elasticbeanstalk-ec2-role.name

  tags = {
    "Name" = "elasticbeanstalk_instance_profile"
  }
}

