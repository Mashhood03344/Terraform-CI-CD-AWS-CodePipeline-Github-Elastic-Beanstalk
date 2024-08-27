# variables.tf

variable "aws_region" {
  description = "The AWS region where resources will be created"
  type        = string
  default     = "us-east-1"  # Change this if needed
}

variable "s3_bucket_name" {
  description = "The name of the S3 bucket to store the application ZIP file"
  type        = string
  default     = "beanstalk-nodejs-app-bucket"  # Ensure this is unique
}

variable "zip_file_path" {
  description = "The local path to the application ZIP file"
  type        = string
  default     = "nodejs.zip"  # Path to your ZIP file, place it in the root of the folder
}

variable "eb_application_name" {
  description = "The name of the Elastic Beanstalk application"
  type        = string
  default     = "my-nodejs-app"
}

variable "eb_environment_name" {
  description = "The name of the Elastic Beanstalk environment"
  type        = string
  default     = "my-nodejs-env"
}

variable "eb_solution_stack" {
  description = "The Elastic Beanstalk solution stack to use"
  type        = string
  default     = "64bit Amazon Linux 2 v5.9.5 running Node.js 18"  # Change this if needed
}

variable "github_repository_owner" {
  description = "GitHub repository owner (username)"
  type = string
  default = "Mashhood03344"# Change to the name to owner of your repo
}

variable "github_repository" {
  description = "GitHub repository name (username/repo)"
  type        = string
  default     = "CI-CD-AWS-CodePipeline-Github-CodeBuild-Elastic-Beanstalk" # Change to the name of your repo
}

variable "github_branch" {
  description = "GitHub repository branch (main)"
  type        = string
  default     = "main"
}

variable "github_oauth_token" {
  description = "GitHub OAuth token for accessing the repository"
  type        = string
  sensitive   = true
  default = "Write-your-own-personal-access-token"
}
