# Highly Available Web Application on AWS using Terraform with GitHub Actions CI/CD

## Overview

This project demonstrates the design, automation, and deployment of a highly available web application infrastructure on AWS using Terraform, integrated with GitHub Actions CI/CD for automated and secure deployments.The infrastructure is built with a multi-AZ architecture, an internet-facing Application Load Balancer, a private Auto Scaling Group for compute, IAM-based access control, and CloudWatch-driven monitoring and scaling.


## Architecture Diagram

![Architecture Diagram](diagrams/architecture.png)


## Architecture Explanation

- The application runs inside a custom VPC spanning two Availability Zones for high availability.
- Public subnets host an internet-facing Application Load Balancer(ALB) that receives client traffic.
- Private subnets host an Auto Scaling Group(ASG) of EC2 instances running the application on port 8080.
- The ALB forwards traffic to a target group associated with the Auto Scaling Group.
- EC2 instances have no public IPs and are accessible only through the ALB.
- IAM roles are attached to EC2 instances using instance profiles to allow secure access to AWS services.
- CloudWatch alarms monitor CPU utilization and trigger scale-out and scale-in actions automatically.


## Traffic Flow

1. Client sends an HTTP request to the Application Load Balancer.
2. The ALB listener receives the request and forwards it to the target group.
3. The target group routes traffic to healthy EC2 instances on port 8080.
4. EC2 instances respond to the request.
5. ALB health checks continuously monitor instance health to ensure only healthy instances receive traffic.


## CI/CD Pipeline

Infrastructure deployments are automated using GitHub Actions, with secure AWS authentication implemented via OpenID Connect (OIDC). This eliminates the need for long-lived AWS access keys in CI/CD.

The pipeline supports two environments:

1. Development (dev) — automatic deployments for rapid iteration
2. Production (prod) — controlled deployments with manual approval

### 1. Dev Deployment

The dev environment is automatically deployed whenever code is pushed to the main branch.

This enables rapid validation of infrastructure changes during development.

Trigger : Push to main branch
#### Pipeline Workflow
```text
Checkout Repository
        ↓
Authenticate to AWS using OIDC
        ↓
Terraform Init
        ↓
Terraform Plan
        ↓
Terraform Apply (dev environment)
```
### 2. Production Deployment

The prod environment uses a controlled deployment process to prevent unintended infrastructure changes.

Production deployments are triggered manually and require approval before applying changes.

Trigger : Manual Trigger (Run workflow)
#### Deployment Workflow
```text
Manual Trigger (GitHub Actions)
        ↓
Checkout Repository
        ↓
Authenticate to AWS using OIDC
        ↓
Terraform Init
        ↓
Terraform Plan
        ↓
Terraform Apply (prod environment)
```

## Terraform Remote State

Terraform states for both environments(dev and prod) is stored remotely to enable safe collaboration and consistent infrastructure management.

Backend configuration:
- S3 Bucket → stores Terraform state file
- DynamoDB Table → state locking

Example state paths:
```text
webapp/dev/terraform.tfstate
webapp/prod/terraform.tfstate
```
This prevents concurrent modifications and state corruption.

## Folder Structure
```text
aws-webapp-terraform/
│
├── modules/
│   ├── vpc/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── alb/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   ├── compute/
│   │   ├── main.tf        # LT + ASG
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── user_data.sh
│   │
│   ├── iam/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   │
│   └── monitoring/
│       ├── main.tf
│       ├── variables.tf
│       └── outputs.tf
│
├── envs/
│   └── dev/
│       ├── main.tf
│       ├── provider.tf
│       ├── backend.tf
│       ├── variables.tf
│       ├── terraform.tfvars
│       └── outputs.tf
│
├── diagrams/
│   └── architecture.png
│
├── README.md
└── .gitignore

```

## Terraform Modules

- **VPC Module**: Creates the VPC, public and private subnets, route tables, IGW, and NAT Gateway.
- **IAM Module**: Defines IAM roles and instance profiles for EC2.
- **ALB Module**: Creates the Application Load Balancer, listener, and target group.
- **Compute Module**: Provisions the Launch Template and Auto Scaling Group.
- **Monitoring Module**: Configures CloudWatch alarms and Auto Scaling policies.

