resource "aws_s3_bucket" "terraform-pipeline-charles-s3" {
  bucket = "terraform-pipeline-charles-s3"
  force_destroy = true
}

resource "aws_dynamodb_table" "terraform-pipeline-charles-dynamo-db" {
  name = "terraform-pipeline-charles-dynamo-db"
  hash_key = "LockID"
  read_capacity = 1
  write_capacity = 1

  attribute {
    name = "LockID"
    type = "S"
  }
}

resource "aws_s3_bucket_versioning" "terraform" {
  bucket = aws_s3_bucket.terraform.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_object" "tfstate" {
  bucket = aws_s3_bucket.terraform.bucket
  key = "terraform.tfstate"
  source = "terraform.tfstate"
}

resource "aws_codecommit_repository" "beanstalk" {
  repository_name = "beanstalk"
  description     = "This is the Sample App Repository"

  tags = {
    "Name" = "beanstalk"
  }
}

resource "aws_codecommit_trigger" "beanstalk" {
  repository_name = aws_codecommit_repository.beanstalk.repository_name

  trigger {
    name            = "all"
    events          = ["all"]
    destination_arn = data.aws_sns_topic.beanstalk.arn
  }
}

resource "null_resource" "codecommit" {

  triggers = {
    codecommit = aws_codecommit_repository.beanstalk.clone_url_http
  }
  # set up https connection to codecommit 
  # https://docs.aws.amazon.com/codecommit/latest/userguide/setting-up-https-unixes.html
  
  # add your username
  # add your email address
  provisioner "local-exec" {
    command = <<-EOT
      git clone ${self.triggers.codecommit} beanstalk && 
      cp -r buildspec beanstalk_infrastructure beanstalk/ && 
      cd beanstalk/ && 
      git status && 
      git config --local user.name ${var.user_name} && 
      git config --local user.email ${var.email} && 
      git add -A && 
      git commit -m 'Added some files' && 
      git push -u origin main
    EOT
  }
}

resource "aws_cloudwatch_log_group" "terraform" {
  name = "terraform"
}

resource "aws_cloudwatch_log_stream" "terraform" {
  log_group_name = aws_cloudwatch_log_group.terraform.name
  name = "terraform"
  
}
resource "aws_codebuild_project" "beanstalk" {
  name = "beanstalk"
  service_role = aws_iam_role.codebuild.arn
  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image = "aws/codebuild/standard:7.0"
    type = "LINUX_CONTAINER"
  }

  source {
    type = "CODEPIPELINE"
     # If this value is not provided, then the source code must 
     # contain a buildspec file named buildspec.yml at the root
     # level. If this value is provided, it can be either a single 
     # string containing the entire build specification, or the 
     # path to an alternate buildspec file relative to the value 
     # of the built-in environment variable CODEBUILD_SRC_DIR.
    buildspec = "buildspec/buildspec.yml"
  }

  logs_config {
    cloudwatch_logs {
      status = "ENABLED"
      group_name = aws_cloudwatch_log_group.terraform.name
      stream_name = aws_cloudwatch_log_stream.terraform.name
    }
  }

  tags = {
    "Name" = "beanstalk"
  }

  depends_on = [ null_resource.codecommit ]
  
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
      output_artifacts = [ "CODE_ZIP" ]

      configuration = {
        "RepositoryName" = aws_codecommit_repository.beanstalk.repository_name
        "BranchName" = "main"
      }
    }
  }

  stage {
    name = "Build"
    action {
      category = "Build"
      name = "Build"
      owner = "AWS"
      provider = "CodeBuild"
      version = "1"
      input_artifacts = [ "CODE_ZIP" ]

      configuration = {
        "ProjectName" = "beanstalk"
      }
    }
  }
}
