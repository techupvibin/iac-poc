# Architecture Notes & Decisions

## POC Scope
This prototype demonstrates the **approach** for IaC automation.
It is not connected to any existing environment.

## Architecture Decisions

### ECS Fargate vs EC2
- Fargate chosen: no EC2 instances to manage, scales to zero, simpler for POC
- FARGATE_SPOT used in sandbox/dev to reduce costs (~70% cheaper)
- Standard Fargate used in preprod/prod for reliability

### Two Pipelines (Infrastructure + Application)
As discussed:
- **Infrastructure pipeline** (`terraform/`): creates VPC, ECS, RDS, ALB, S3, IAM
- **Application pipeline** (`.gitlab-ci.yml` build stage): builds Docker image, pushes to ECR, updates ECS task definition

These are intentionally separate — infra changes are rarer and need more review.

### No Kubernetes
As discussed — ECS Fargate chosen over EKS/K8s for this POC:
- Simpler to operate
- Native AWS integration (IAM, Secrets Manager, CloudWatch)
- Less overhead for small team
- Can migrate to EKS later if needed

### Apollo Router (Future)
When the dev team is ready:
- Apollo Router runs on an EC2 instance (as per current architecture)
- An `ec2` Terraform module can be added: SG, instance, user_data to install Apollo Router
- This module is **not in the POC scope** — added as follow-on

### Secrets Management
- No hardcoded credentials anywhere
- Terraform generates random passwords and stores in Secrets Manager
- ECS tasks retrieve secrets at runtime via `secrets:` in task definition
- GitLab pipeline uses OIDC (or env vars) — no static keys in code

## Next Steps (Post-POC)
1. Adapt tfvars to match real AWS account structure
2. Get access to existing sandbox + migrate existing resources to Terraform state
3. Add Apollo Router EC2 module
4. Wire RDS username into Secrets Manager (currently only password)
5. Add WAF module for production
6. Add VPC Flow Logs module
