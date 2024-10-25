# Cloud Resume Challenge - Terraform Automation

This repository contains the code to automate the infrastructure of the Cloud Resume Challenge using Terraform. The project includes an S3-hosted static website, a CloudFront distribution, a Lambda function to track visitors, and a DynamoDB table to store visitor counts.

## Project Overview

The Cloud Resume Challenge is a hands-on project where we create a resume website, track visitor counts using a Lambda function, and manage the infrastructure in the cloud. This repository provides a fully automated solution using Terraform to provision AWS resources.

## Architecture Diagram

Below is the architecture used in this project:

- S3: Hosts the static website files.
- CloudFront: Distributes the website globally with low latency.
- Lambda: Increments visitor count stored in DynamoDB.
- DynamoDB: Stores the number of visitors.
- IAM Role: Manages permissions for Lambda to interact with DynamoDB.

## Project Structure

```
├── cloudfront.tf            # CloudFront distribution configuration  
├── dynamodb.tf              # DynamoDB table for visitor count  
├── lambda.tf                # Lambda function setup and IAM role  
├── lambda.py                # Python code for Lambda function  
├── main.tf                  # Terraform main configuration file  
├── provider.tf              # AWS provider setup  
├── s3.tf                    # S3 bucket for static site hosting  
├── bucketpolicy.tf          # Policy to allow CloudFront access to S3  
├── README.md                # Project documentation (this file)  
```
## Prerequisites

1. Terraform: Install Terraform from terraform.io.
2. AWS Account: Ensure you have an AWS account and permissions to create resources.

## Installation and Usage

1. Clone the Repository

``` bash

git clone https://github.com/your-username/cloud-resume-challenge-terraform.git
cd cloud-resume-challenge-terraform

```
2. Initialize Terraform

``` bash

terraform init

```
3. Preview the Plan

``` bash

terraform plan

```

4. Deploy the Infrastructure

``` bash

terraform apply

```

5. Test Lambda Function
Once deployed, trigger the Lambda function via the AWS console or a CloudFront request.

## Lambda Function Code
Below is the code used in the lambda.py file, which increments the visitor count stored in DynamoDB:

``` python

import boto3

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table("visitors-count")

def lambda_handler(event, context):
    item = table.get_item(Key={"id": "0"})
    views = item["Item"]["views"]

    views += 1

    table.put_item(Item={"id": "0", "views": views})

    return views

```

## Demo
Check out the live version of the website via CloudFront:
🔗[Live Demo](https://d27jw4lpo7wsxn.cloudfront.net/)

## GitHub Actions Integration
This project can be further automated using GitHub Actions for continuous deployment. Make sure to add the necessary secrets to the repository to enable CI/CD.

## Resources Used
- AWS S3: Static website hosting
- AWS CloudFront: Content delivery network
- AWS Lambda: Serverless compute for visitor tracking
- DynamoDB: NoSQL database to store visitor counts
- Terraform: Infrastructure as Code (IaC)

## Contributing
Feel free to fork this repository, open issues, or submit pull requests. Contributions are welcome!
