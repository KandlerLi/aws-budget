# AWS Budget alert

A single `aws_budgets_budget` resource: a $10/month cost budget with three
email notifications to `julian.kandler@outlook.com` (configurable via
`alert_email`):

- 80% of actual spend (early warning)
- 100% of actual spend (the limit has actually been reached)
- 100% of forecasted spend (AWS predicts the month will exceed the limit,
  even before actual spend gets there)

## Why USD, not EUR

This AWS account bills in USD (confirmed via `aws ce get-cost-and-usage`),
regardless of the rest of this workspace being European. AWS Budgets
compares against the account's actual billing currency, so the limit is
set in USD to match exactly rather than as an approximate EUR conversion
that would drift from round as exchange rates move.

## Prerequisites

- Terraform 1.10 or newer
- The `jkandler-terraform-state` S3 backend bucket
- AWS credentials with permission to manage AWS Budgets

## Deploy

```bash
terraform init
terraform plan
terraform apply
```

The S3 backend uses `aws-budget/terraform.tfstate` and native S3 lock
files.

## Local validation

```bash
terraform fmt -check -recursive
terraform init -backend=false
terraform validate
```
