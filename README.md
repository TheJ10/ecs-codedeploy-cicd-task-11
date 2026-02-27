# Task 11 – ECS Blue/Green Deployment with GitHub Actions & CodeDeploy

## Objective

Implement a fully automated CI/CD pipeline for deploying a Dockerized Strapi application to AWS ECS using:

- Amazon ECR
- Amazon ECS (Fargate)
- AWS CodeDeploy (Blue/Green)
- GitHub Actions

The pipeline must:

1. Build Docker image on every push
2. Tag image with GitHub Commit SHA
3. Push image to Amazon ECR
4. Register new ECS Task Definition revision dynamically
5. Trigger AWS CodeDeploy Blue/Green deployment
6. Wait for deployment success
7. Automatically rollback on failure

---

## Architecture Overview

GitHub → CI (Build & Push Image) → ECR  
GitHub → CD → Register New Task Definition → CodeDeploy → ECS Blue/Green → ALB

---

## Technologies Used

- AWS ECS (Fargate)
- AWS ECR
- AWS CodeDeploy
- AWS RDS (PostgreSQL)
- Application Load Balancer (ALB)
- Terraform
- GitHub Actions
- Docker
- jq (for JSON manipulation)

---

## CI Workflow (ci.yml)

Triggered on push to main branch.

### Steps:
- Checkout repository
- Configure AWS credentials
- Login to Amazon ECR
- Generate image tag from GitHub SHA
- Build Docker image
- Push image to ECR

Image tagging format:
```bash
<account-id>.dkr.ecr.us-east-1.amazonaws.com/jaspal-task11-strapi:<commit-sha>
```

---

##  CD Workflow (deploy.yml)

Triggered manually using workflow_dispatch with image_tag input.

### CD Process:

1. Download current ECS task definition
2. Replace container image with new commit SHA
3. Register new task definition revision
4. Fetch latest task definition ARN
5. Create AppSpec JSON dynamically
6. Trigger AWS CodeDeploy deployment
7. Wait for deployment success

Blue/Green deployment configuration:
```bash
CodeDeployDefault.ECSCanary10Percent5Minutes
```

---

## Terraform Infrastructure

Provisioned resources:

- ECS Cluster
- ECS Service (CODE_DEPLOY controller)
- ECS Task Definition
- ECR Repository
- RDS PostgreSQL Instance
- ALB (Blue & Green Target Groups)
- CodeDeploy Application
- CodeDeploy Deployment Group

---

## Blue/Green Deployment Flow

1. New task definition revision created
2. CodeDeploy launches replacement task set
3. ALB health checks validate container
4. Traffic shifts gradually (10% → 100%)
5. Old task set terminated automatically

Rollback occurs automatically if deployment fails.

---

## IAM Permissions Required

IAM user must have:

- AmazonEC2ContainerRegistryFullAccess
- ECS permissions
- CodeDeploy permissions

---

## Deployment Testing

To deploy a new version:

1. Push changes to main branch
2. CI builds and pushes image
3. Run CD workflow manually
4. Provide new image tag (commit SHA)
5. Monitor CodeDeploy progress

---

## Final Outcome

A fully automated CI/CD pipeline capable of:

- Building Docker image automatically
- Updating ECS task definition dynamically
- Performing Blue/Green deployments
- Handling rollback automatically
- Eliminating manual task definition management

---

## Repository Structure
```text
task-11-ecs-codedeploy-cicd/
│
├── strapi/
├── terraform/
│ ├── modules/
│ ├── main.tf
│ └── variables.tf
│
└── .github/workflows/
├── ci.yml
└── deploy.yml
```

---

## Key Learning Outcomes

- ECS deployment controller (CODE_DEPLOY)
- Blue/Green deployment strategy
- Dynamic task definition revision management
- GitHub Actions CI/CD integration with AWS
- Troubleshooting ECS container crashes
- IAM permission debugging

---

## Author
Jaspal Gundla  
