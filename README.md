# Elastic Beanstalk Deployment and CI/CD Pipeline with Terraform

## Overview

This project demonstrates how to deploy an application using AWS Elastic Beanstalk and how to set up a CI/CD pipeline using AWS CodePipeline. The infrastructure is defined using Terraform, which automates the provisioning of AWS resources required for the deployment.

## Features

- Elastic Beanstalk Deployment: Automatically deploy an application to AWS Elastic Beanstalk.
- IAM Roles: Create IAM roles with necessary permissions for Elastic Beanstalk and EC2 instance - s.
- S3 Bucket: Store the application source code in an S3 bucket.
- CI/CD Pipeline: Set up a CI/CD pipeline using AWS CodePipeline to automate the deployment process.
- Prerequisites

### Before you begin, ensure you have the following:

- Terraform: Installed and configured on your local machine.
- AWS Account: Access to an AWS account with necessary permissions to create and manage resources.
- GitHub Repository: A GitHub repository containing your application code.
- Personal Access Token (PAT): A GitHub PAT with sufficient permissions to access your repository.
- Setup Instructions
    - **Step 1: Clone the Repository**
      
	Clone this repository to your local machine:
	
	```bash
	git clone <repository-url>
	cd <repository-folder>
	```
	
    - **Step 2**: 
    
	Configure Your Application Repository After cloning this repository, create another repository for your application code. Only the application code files should be placed in this new repository—not  t
	the entire folder.

   - **Step 3**: 
   
   	Update variables.tf
	
	In the variables.tf file, update the following variables:

	 - GitHub Repository Owner: Set the github_repository_owner variable to the name of the owner of your repository.
	 - GitHub Repository Name: Set the github_repository variable to the name of your repository.
	 - Personal Access Token: Set the github_oauth_token variable to your GitHub PAT.
	
	Example:

	```bash
	variable "github_repository_owner" {
	  description = "The owner of the GitHub repository"
	  type        = string
	  default     = "your-github-username"
	}

	variable "github_repository" {
	  description = "The name of the GitHub repository"
	  type        = string
	  default     = "your-repo-name"
	}

	variable "github_oauth_token" {
	  description = "Your GitHub personal access token"
	  type        = string
	  default     = "your-github-pat"
	}
	```
	
   - **Step 4:** Initialize and Apply Terraform
	Initialize the Terraform configuration:


	```bash
	terraform init
	```

	Apply the Terraform configuration to provision the AWS resources:

	```bash
	terraform apply
	```
	
## Services Overview

 - Elastic Beanstalk Deployment
 - S3 Bucket: Stores the application code.
 - IAM Roles: Roles and policies for Elastic Beanstalk and EC2 instances.
 - Elastic Beanstalk Application: Defines the Elastic Beanstalk application and its environment.
 - CI/CD Pipeline
 - CodePipeline IAM Role: Grants necessary permissions to CodePipeline.
 - CodePipeline: Automates the deployment process by fetching the application code from GitHub and deploying it to Elastic Beanstalk.
 - Resources Created
 - S3 Bucket: aws_s3_bucket.app_bucket
 - IAM Roles: aws_iam_role.eb_service_role, aws_iam_role.eb_instance_role
 - Elastic Beanstalk Application: aws_elastic_beanstalk_application.app
 - CodePipeline: aws_codepipeline.app_pipeline


## Cleanup

To destroy all the resources created by Terraform, run:

	```bash
	terraform destroy
	```

## Notes
 - Ensure that your GitHub repository only contains the application code files.
 - The S3 bucket and other resources will be created based on the values provided in the variables.tf 
