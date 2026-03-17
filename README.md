# IaC POC — AWS Infrastructure Prototype

> **Prototype Notice:** This is a proof-of-concept built in an isolated sandbox environment.
> Demonstrates approach and methodology — not a production-ready deployment.
> Full hardening is a follow-on engagement.

---

## What This Deploys

```
Internet
   │
   └─► Route53 alias
           │
           └─► ALB (HTTPS/443 + HTTP→HTTPS redirect, TLS 1.3)
                   │
                   ├─► ECS Fargate — Frontend  (Node.js :3000)
                   └─► ECS Fargate — Backend   (Node.js API :4000)
                               │
                               ├─► RDS PostgreSQL 16.2 (private subnet)
                               ├─► S3 Bucket (app assets, SSE-AES256)
                               └─► Secrets Manager (db_password, app_secret)
```

| Component | Module | Resources |
|---|---|---|
| Network | `modules/network` | VPC, public/private subnets, IGW, NAT GW, route tables |
| Security | `modules/security_groups` | ALB SG (80/443), ECS SG, RDS SG |
| Registry | `modules/ecr` | ECR × 2 with lifecycle policy |
| TLS | `modules/acm` | ACM cert DNS-validated via Route53 |
| Load Balancer | `modules/alb` | ALB, target groups, HTTP→HTTPS, TLS 1.3 |
| Compute | `modules/ecs` | Fargate cluster, task defs, services, auto-scaling |
| Database | `modules/rds` | PostgreSQL 16.2, gp3, encrypted at rest |
| Storage | `modules/s3` | S3 bucket, SSE-AES256, public access blocked |
| Secrets | `modules/secrets` | db_password + app_secret in Secrets Manager |
| Monitoring | `modules/cloudwatch` | CPU/Mem/RDS alarms + dashboard |

---

## Prerequisites

```bash
terraform >= 1.5.0
aws-cli   >= 2.x
docker    >= 24.x

# Verify
terraform version && aws --version && docker --version
```

---

## Step 1 — AWS Access

```bash
aws configure
# AWS Access Key ID:     <your-key>
# AWS Secret Access Key: <your-secret>
# Default region:        ap-southeast-2
# Default output format: json

# Verify
aws sts get-caller-identity
```

---

## Step 2 — Remote State Setup (run once)

```bash
REGION="ap-southeast-2"
BUCKET="my-terraform-state-poc-$(date +%s)"

aws s3api create-bucket --bucket $BUCKET --region $REGION \
  --create-bucket-configuration LocationConstraint=$REGION

aws s3api put-bucket-versioning --bucket $BUCKET \
  --versioning-configuration Status=Enabled

aws dynamodb create-table \
  --table-name terraform-state-lock \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST --region $REGION

echo "Update terraform/backend.tf with bucket: $BUCKET"
```

---

## Step 3 — Configure Your Environment

```bash
cd terraform/
cp environments/sandbox/terraform.tfvars terraform.tfvars
```

Edit `terraform.tfvars` — minimum required changes:
```hcl
aws_region     = "ap-southeast-2"
project_name   = "myapp"
environment    = "sandbox"
# Optional — set false to skip DNS and use ALB endpoint directly
create_route53_record = false
```

---

## Step 4 — Deploy ECR First, Then Push Images

```bash
cd terraform/

# Init and create ECR repos first
terraform init
terraform apply -target=module.ecr -auto-approve

# Get account ID + login to ECR
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
export AWS_REGION="ap-southeast-2"
export ECR_BASE="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com"

aws ecr get-login-password --region $AWS_REGION | \
  docker login --username AWS --password-stdin $ECR_BASE

# Build + push frontend
cd ../app/frontend
docker build -t myapp-frontend .
docker tag myapp-frontend:latest $ECR_BASE/myapp-frontend:latest
docker push $ECR_BASE/myapp-frontend:latest

# Build + push backend
cd ../backend
docker build -t myapp-backend .
docker tag myapp-backend:latest $ECR_BASE/myapp-backend:latest
docker push $ECR_BASE/myapp-backend:latest
```

---

## Step 5 — Deploy Full Infrastructure

```bash
cd terraform/
terraform plan          # Review what will be created (~40 resources)
terraform apply         # Type 'yes' to confirm

# After apply — outputs printed:
# alb_dns_name     = "myapp-alb-xxx.ap-southeast-2.elb.amazonaws.com"
# ecr_frontend_url = "123456789.dkr.ecr..."
# rds_endpoint     = "myapp-db.xxx.rds.amazonaws.com"
```

---

## Step 6 — Verify

```bash
ALB=$(terraform output -raw alb_dns_name)

# Frontend
curl -I http://$ALB/

# Backend health check
curl http://$ALB/api/health
# Expected: {"status":"ok","environment":"sandbox","timestamp":"..."}
```

---

## Step 7 — GitLab Pipeline Setup

Add these CI/CD variables in GitLab → Settings → CI/CD → Variables:

| Variable | Value | Masked |
|---|---|---|
| `AWS_ACCESS_KEY_ID` | your key | ✅ |
| `AWS_SECRET_ACCESS_KEY` | your secret | ✅ |
| `AWS_DEFAULT_REGION` | ap-southeast-2 | No |
| `TF_STATE_BUCKET` | your-bucket-name | No |
| `TF_STATE_LOCK_TABLE` | terraform-state-lock | No |

Pipeline stages: `validate → plan → [manual approve] → apply`

---

## Step 8 — Cleanup

```bash
cd terraform/
terraform destroy    # Removes ALL resources — stops all AWS costs
# Type 'yes' to confirm
```

---

## Environment Reference

| Setting | Sandbox | Dev | Preprod | Prod |
|---|---|---|---|---|
| VPC CIDR | 10.0.0.0/16 | 10.1.0.0/16 | 10.2.0.0/16 | 10.3.0.0/16 |
| Fargate type | SPOT | SPOT | Standard | Standard |
| Task CPU/Mem | 256/512 | 512/1024 | 1024/2048 | 2048/4096 |
| Auto-scale | 1–2 | 1–3 | 2–6 | 2–10 |
| RDS class | db.t3.micro | db.t3.small | db.t3.medium | db.r6g.large |
| Multi-AZ RDS | ❌ | ❌ | ✅ | ✅ |
| ECR mutability | MUTABLE | MUTABLE | IMMUTABLE | IMMUTABLE |
| Log retention | 7d | 14d | 30d | 90d |

---

## Troubleshooting

| Error | Fix |
|---|---|
| `no valid credential sources` | Run `aws configure` |
| `S3 bucket already exists` | Change bucket name in `backend.tf` |
| `ECR repo not found` when pushing | Run `terraform apply -target=module.ecr` first |
| `domain not found` | Set `create_route53_record = false` in tfvars |
| `Access Denied` in GitLab pipeline | Check AWS vars are set + Protected in GitLab |
| `ResourceInUseException` on DynamoDB | Table already exists — skip that command |
