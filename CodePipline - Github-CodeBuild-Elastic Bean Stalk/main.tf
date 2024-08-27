//////////// Elastice Beanstalk deployment




// S3 Bucket for Application
resource "aws_s3_bucket" "app_bucket" {
  bucket = var.s3_bucket_name
  tags = {
    Name = "AppBucket"
  }
}

resource "aws_s3_object" "app_zip" {
  bucket = aws_s3_bucket.app_bucket.bucket
  key    = basename(var.zip_file_path)
  source = var.zip_file_path
  etag   = filemd5(var.zip_file_path)
}

// IAM Roles for Elastic Beanstalk Service

// IAM Beanstalk Service Role
resource "aws_iam_role" "eb_service_role" {
  name = "eb-service-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "elasticbeanstalk.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

// attaching the /service-role/AWSElasticBeanstalkEnhancedHealth to the eb_service_role
resource "aws_iam_role_policy_attachment" "eb_service_role_policy" {
  role       = aws_iam_role.eb_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSElasticBeanstalkEnhancedHealth"
}

// attaching the /AWSElasticBeanstalkManagedUpdatesCustomerRolePolicy to the eb_service_role
resource "aws_iam_role_policy_attachment" "eb_service_managed_updates_policy" {
  role       = aws_iam_role.eb_service_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkManagedUpdatesCustomerRolePolicy"
}

// IAM Role for EC2 Instances
resource "aws_iam_role" "eb_instance_role" {
  name = "eb-instance-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ec2_full_access_policy" {
  role       = aws_iam_role.eb_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_role_policy_attachment" "s3_access_policy" {
  role       = aws_iam_role.eb_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "xray_access_policy" {
  role       = aws_iam_role.eb_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSXRayDaemonWriteAccess"
}

resource "aws_iam_role_policy_attachment" "cloudwatch_logs_access_policy" {
  role       = aws_iam_role.eb_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_iam_role_policy_attachment" "eb_health_access_policy" {
  role       = aws_iam_role.eb_instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier"
}

resource "aws_iam_instance_profile" "eb_instance_profile" {
  name = "eb-instance-profile"
  role = aws_iam_role.eb_instance_role.name
}

// Elastic Beanstalk Application and Environment
resource "aws_elastic_beanstalk_application" "app" {
  name = var.eb_application_name
}

resource "aws_elastic_beanstalk_application_version" "app_version" {
  name        = "v1"
  application = aws_elastic_beanstalk_application.app.name
  bucket      = aws_s3_bucket.app_bucket.bucket
  key         = aws_s3_object.app_zip.key
}

resource "aws_elastic_beanstalk_environment" "app_env" {
  name                = var.eb_environment_name
  application         = aws_elastic_beanstalk_application.app.name
  solution_stack_name = var.eb_solution_stack

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "NODE_ENV"
    value     = "production"
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = aws_iam_instance_profile.eb_instance_profile.name
  }

  setting {
    namespace = "aws:elasticbeanstalk:environment"
    name      = "ServiceRole"
    value     = aws_iam_role.eb_service_role.name
  }

  version_label = aws_elastic_beanstalk_application_version.app_version.name
}



/////// CI/CD pipeline

// Define the IAM Role for CodePipeline
resource "aws_iam_role" "codepipeline_role" {
  name = "codepipeline-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

// Attach necessary policies to the CodePipeline role
// Attach necessary policies to the CodePipeline role
resource "aws_iam_role_policy_attachment" "codepipeline_role_policy" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSCodePipeline_FullAccess" 
}

resource "aws_iam_role_policy_attachment" "codepipeline_s3_policy" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "codepipeline_eb_policy" {
  role       = aws_iam_role.codepipeline_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess-AWSElasticBeanstalk"
}


// Define the CodePipeline
resource "aws_codepipeline" "app_pipeline" {
  name     = "elasticbeanstalk-app-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.app_bucket.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        Owner         = var.github_repository_owner
        Repo          = var.github_repository
        Branch        = var.github_branch
        OAuthToken    = var.github_oauth_token
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name             = "Deploy"
      category         = "Deploy"
      owner            = "AWS"
      provider         = "ElasticBeanstalk"
      version          = "1"
      input_artifacts  = ["source_output"]

      configuration = {
        ApplicationName = aws_elastic_beanstalk_application.app.name
        EnvironmentName = aws_elastic_beanstalk_environment.app_env.name
      }
    }
  }
}

// Optional: Define an S3 bucket for storing pipeline artifacts
resource "aws_s3_bucket" "pipeline_artifact_store" {
  bucket = "${var.s3_bucket_name}-pipeline-artifacts"
  tags = {
    Name = "PipelineArtifactStore"
  }
}
