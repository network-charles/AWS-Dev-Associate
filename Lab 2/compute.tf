resource "aws_codecommit_repository" "test" {
  repository_name = "test"
  description     = "This is the Sample App Repository"
}

resource "null_resource" "codecommit" {

  triggers = {
    codecommit = aws_codecommit_repository.test.clone_url_ssh
  }
  # use ssh-keyscan to bypass auth once
  provisioner "local-exec" {
    command = "ssh-keyscan -H git-codecommit.<region>.amazonaws.com >> ~/.ssh/known_hosts && ssh-keyscan -H <IP-address of git-codecommit.<region>.amazonaws.com> >> ~/.ssh/known_hosts && git clone ${self.triggers.codecommit} test && cp Dockerfile buildspec.yml test/ && cd test && git status && git config --local user.name 'network-charles' && git config --local user.email <email> && git add . && git commit -m 'Added some files' && git push -u origin master"
  }
}

resource "aws_ecr_repository" "test" {
  name                 = "test"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  depends_on = [ null_resource.codecommit ]
}

resource "aws_codebuild_project" "name" {
  name = "value"
  service_role = aws_iam_role.codebuild.arn
  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image = "aws/codebuild/standard:5.0"
    type = "LINUX_CONTAINER"

    environment_variable {
      name = "IMAGE_REPO_NAME"
      value = "test"
    }

    environment_variable {
      name = "IMAGE_TAG"
      value = "latest"
    }

    environment_variable {
      name = "AWS_DEFAULT_REGION"
      value = "eu-west-2"
    }

    environment_variable {
      name = "AWS_ACCOUNT_ID"
      value = data.aws_caller_identity.current.account_id
    }
  }

  source {
    type = "CODECOMMIT"
    location = aws_codecommit_repository.test.clone_url_http
  }

  logs_config {
    cloudwatch_logs {
      status = "DISABLED"
    }
  }

  depends_on = [ null_resource.codecommit ]
  
}
