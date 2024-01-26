resource "aws_elastic_beanstalk_application" "flask" {
  name        = "flask"
  description = "event-driven-app beanstalk deployment"
}

resource "aws_elastic_beanstalk_environment" "dev_env" {
  name                = "dev-env"
  application         = aws_elastic_beanstalk_application.flask.name
  tier                = "WebServer"
  version_label = aws_elastic_beanstalk_application_version.flask-v1.id
  template_name = aws_elastic_beanstalk_configuration_template.flask_template.name

  tags = {
    "Name" = "dev_env"
  }
}

resource "aws_s3_bucket" "flask" {
  bucket = "flask.uneze"
  force_destroy = true
}

resource "aws_s3_object" "flask-v1" {
  bucket = aws_s3_bucket.flask.bucket
  key = "flask_v1/flask-v1.zip"
  source = "flask_v1/flask-v1.zip"
}

resource "aws_s3_object" "flask-v2" {
  bucket = aws_s3_bucket.flask.bucket
  key = "flask_v2/flask-v2.zip"
  source = "flask_v2/flask-v2.zip"
}

resource "aws_elastic_beanstalk_application_version" "flask-v1" {
  name        = "flask-v1"
  application = aws_elastic_beanstalk_application.flask.name
  description = "application version created by terraform"
  bucket      = aws_s3_bucket.flask.id
  key         = aws_s3_object.flask-v1.id
  force_delete = true

  tags = {
    "Name" = "flask-v1"
  }
}

resource "aws_elastic_beanstalk_application_version" "flask-v2" {
  name        = "flask-v2"
  application = aws_elastic_beanstalk_application.flask.name
  description = "application version created by terraform"
  bucket      = aws_s3_bucket.flask.id
  key         = aws_s3_object.flask-v2.id

  tags = {
    "Name" = "flask-v2"
  }
}

resource "aws_elastic_beanstalk_configuration_template" "flask_template" {
  name                = "flask-template-config"
  application         = aws_elastic_beanstalk_application.flask.name
  solution_stack_name = "64bit Amazon Linux 2023 v4.0.7 running Python 3.11"

  setting {
    namespace = "aws:ec2:vpc"
    name      = "VPCId"
    value     = aws_vpc.elastic_beanstalk.id
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = aws_subnet.public1.id
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "Subnets"
    value     = aws_subnet.public2.id
  }

  setting {
    namespace = "aws:ec2:vpc"
    name      = "AssociatePublicIpAddress"
    value     = "true"
  }

  setting {
    namespace = "aws:ec2:instances"
    name      = "SupportedArchitectures"
    value     = "x86_64"
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "EnvironmentType"
    value     = "SingleInstance"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType" 
    value     = "t3.micro"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile" 
    value     = aws_iam_instance_profile.elasticbeanstalk_instance_profile.arn
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "EC2KeyName" 
    value     = ""
  }

  setting {
    namespace = "aws:elasticbeanstalk:command"
    name      = "DeploymentPolicy" 
    value     = "AllAtOnce"
  }

}

# Store DNS name in SSM Parameter Store
resource "aws_ssm_parameter" "eb_dns_param" {
  name  = "eb_dns_name"
  type  = "String"
  value = aws_elastic_beanstalk_environment.dev_env.cname
}

# Use local-exec provisioner to send a message to the SNS topic with the DNS name
resource "null_resource" "send_notification" {
  triggers = {
    dns_name = aws_ssm_parameter.eb_dns_param.value
    topic_arn = data.aws_sns_topic.aws_ssm_parameter.arn
  }

  provisioner "local-exec" {
    command = <<-EOT
      aws sns publish --topic-arn ${self.triggers.topic_arn} \
      --message "The Elastic Beanstalk DNS name is: ${self.triggers.dns_name}"
    EOT
  }
}

