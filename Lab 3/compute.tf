resource "aws_codecommit_repository" "codedeploy" {
  repository_name = "codedeploy"
  description     = "This is the Sample App Repository"
}

resource "aws_codecommit_trigger" "codedeploy" {
  repository_name = aws_codecommit_repository.codedeploy.repository_name

  trigger {
    name            = "all"
    events          = ["all"]
    destination_arn = data.aws_sns_topic.codedeploy.arn
  }
}

resource "null_resource" "codecommit" {

  triggers = {
    codecommit = aws_codecommit_repository.codedeploy.clone_url_http
  }

  # set up https connection to codecommit 
  # https://docs.aws.amazon.com/codecommit/latest/userguide/setting-up-https-unixes.html
  
  # add your username
  # add your email address
  provisioner "local-exec" {
    command = <<-EOT
      git clone ${self.triggers.codecommit} codedeploy && 
      cp -r website/* codedeploy/ && cd codedeploy/ && 
      git status && git config --local user.name ${var.user_name} && 
      git config --local user.email ${var.email} && git add -A && 
      git commit -m 'Added some files' && git push -u origin master
    EOT
  }
}

resource "aws_codedeploy_app" "web" {
  name = "web"
  compute_platform = "Server"
}

resource "aws_codedeploy_deployment_group" "web" {
  app_name = aws_codedeploy_app.web.name
  deployment_group_name = "web"
  service_role_arn = aws_iam_role.codedeploy.arn
  deployment_config_name = "CodeDeployDefault.OneAtATime"

  ec2_tag_set {
    ec2_tag_filter {
      key   = "Name"
      type  = "KEY_AND_VALUE"
      value = "codedeploy"
    }
  }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  trigger_configuration {
    trigger_events     = ["DeploymentFailure", "DeploymentSuccess"]
    trigger_name       = "ec2-trigger"
    trigger_target_arn = data.aws_sns_topic.codedeploy.arn
  }

  tags = {
    "Name" = "web"
  }

  depends_on = [ aws_instance.Linux ]
}

resource "aws_instance" "Linux" {
  ami = var.ubuntu
  instance_type = "t3.micro"
  key_name      = var.key_name
  subnet_id = aws_subnet.Public_Subnet.id
  security_groups = [ aws_security_group.SG.id ]
  iam_instance_profile = aws_iam_instance_profile.EC2.name
  tenancy = "default"
  user_data = file("${path.module}/codedeployagent.sh")

  tags = {
    "Name" = "codedeploy"
  }
}

resource "aws_s3_bucket" "codepipeline" {
  bucket = "codepipeline-artifact-uneze"
  force_destroy = true
}

resource "aws_codepipeline" "web" {
  name = "web"
  role_arn = aws_iam_role.codepipeline.arn

  artifact_store {
    location = aws_s3_bucket.codepipeline.bucket
    type = "S3"
  }

  stage {
    name = "Source"
    action {
      category = "Source"
      name = "Source"
      owner = "AWS"
      provider = "CodeCommit"
      version = "1"
      region = "eu-west-2"
      output_artifacts = [ "CODE_ZIP" ]

      configuration = {
        "RepositoryName" = aws_codecommit_repository.codedeploy.repository_name
        "BranchName" = "master"
      }
    }
  }

  stage {
    name = "Deploy"
    action {
      category = "Deploy"
      name = "Deploy"
      owner = "AWS"
      provider = "CodeDeploy"
      version = "1"
      input_artifacts = [ "CODE_ZIP" ]

      configuration = {
        "ApplicationName" = aws_codedeploy_app.web.name
        "DeploymentGroupName" = aws_codedeploy_deployment_group.web.deployment_group_name
      }
    }
  }
}
