# outputs.tf

output "s3_bucket_name" {
  description = "The name of the S3 bucket storing the application ZIP file"
  value       = aws_s3_bucket.app_bucket.bucket
}

output "eb_application_name" {
  description = "The name of the Elastic Beanstalk application"
  value       = aws_elastic_beanstalk_application.app.name
}

output "eb_environment_name" {
  description = "The name of the Elastic Beanstalk environment"
  value       = aws_elastic_beanstalk_environment.app_env.name
}

output "eb_environment_url" {
  description = "The URL of the Elastic Beanstalk environment"
  value       = aws_elastic_beanstalk_environment.app_env.endpoint_url
}
