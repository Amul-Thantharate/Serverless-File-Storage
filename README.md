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
    terraform apply -var-file="pro.vars" -auto-approve
```

6. Go to the AWS Management Console and navigate to the API Gateway service. You should see a new API created. Copy the api endpoint and paste in the app.js file in the front-end folder.

```bash
    cd ../front-end
    vi app.js
```

7. Copy the index.html and app.js file to the S3 bucket

```bash
    aws s3 cp index.html s3://<bucket-name>
    aws s3 cp app.js s3://<bucket-name>
    aws s3 cp style.css s3://<bucket-name>
```

8. Run the Terraform output command to get the CloudFront URL

```bash
    terraform output
```

9. Open the CloudFront URL in the browser and you should see the file upload page.

10. Upload a file and you should see the file being uploaded to the S3 bucket.

11. Go to the S3 bucket and you should see the file uploaded.

12. Go to the CloudFront URL and you should see the file being served from the CloudFront distribution.

## Conclusion

In this project, we have implemented a file storage service using API Gateway, Lambda, S3, and CloudFront. We have used Terraform to create the infrastructure. We have also used the AWS CLI to upload the files to the S3 bucket. We have also used the AWS Management Console to view the API Gateway, S3, and CloudFront services. We have also used the CloudFront URL to view the file being served from the CloudFront distribution.

## Clean Up

To clean up the infrastructure, run the following command

```bash
    terraform destroy -var-file="pro.vars" -auto-approve
```

## References

- [Terraform](https://www.terraform.io/)
- [AWS CLI](https://aws.amazon.com/cli/)
- [AWS Management Console](https://aws.amazon.com/console/)
- [API Gateway](https://aws.amazon.com/api-gateway/)
- [Lambda](https://aws.amazon.com/lambda/)
- [S3](https://aws.amazon.com/s3/)
- [CloudFront](https://aws.amazon.com/cloudfront/)

## License

This project is open source and available under the [MIT License](LICENSE).

## Author

[Amul Thantharate](https://www.linkedin.com/in/amul-thantharate-7b2b3b1a3/)

## Thank You !! 🙌🙌🙌🙌