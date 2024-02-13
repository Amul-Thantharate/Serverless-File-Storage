## Implementing a file storage service for user content using API Gateway, Lambda, S3 and CLoudFront

## Architecture Diagram 
![Architecture](Project.gif)

## Introduction

The need for data accessibility, scalability, and dependability in today’s digital environment drives the usage and development of cloud file storage services. These powerful solutions go beyond conventional constraints, enabling both individuals and enterprises to fully utilize the cloud’s limitless potential. Storing files in the cloud opens up amazing possibilities. It’s like having a superpower for your data with unlimited scalability!

### The service will be implemented using the following

- **Amazon API Gateway** to create a RESTful API to upload files
- **AWS Lambda** to process the uploaded files
- **Amazon S3** to store the uploaded files
- **Aws CloudFront** to serve the files to the users
- **Terrform** to create the infrastructure

## Prerequisites

- **AWS Account**: You will need an AWS account to begin with. You can create one [here](https://aws.amazon.com/).
- **Terraform**: You will need to have Terraform installed on your local machine. You can download it [here](https://www.terraform.io/downloads.html).
- **AWS CLI**: You will need to have the AWS CLI installed on your local machine. You can download it [here](https://aws.amazon.com/cli/).
- **AWS Credentials**: You will need to have your AWS credentials configured on your local machine. You can do this by running `aws configure` on your terminal and following the prompts.

## Getting Started

1. Clone the repository

```bash
    git clone https://github.com/Amul-Thantharate/Serverless-File-Storage.git
```

2. Configure the AWS credentials

```bash
    aws configure
```

3. Change into the project directory

```bash
    cd Serverless-File-Storage
```

4. Add the account id in pro.vars file and also change the backend bucket name in backend.tf file

```bash
    cd serverless-file-storage && cd tf-aws-infra 
    vi pro.vars
    vi backend.tf
```

5. Run the following commands to create the infrastructure

```bash
    terraform init
    terraform apply
```