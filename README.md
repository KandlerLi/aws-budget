# AWS Budget alert

A single `aws_budgets_budget` resource: a $10/month cost budget with three
email notifications to the address configured via `alert_email`:

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

## `alert_email` has no default, deliberately

This repository is public. The notification address isn't committed to
git history — it's supplied via `TF_VAR_alert_email`, sourced from this
repository's own `ALERT_EMAIL` GitHub Actions variable, the same pattern
`dyndns`/`website` use for `ROUTE53_ZONE_ID`. Set it locally as an
environment variable (or in a gitignored `terraform.tfvars`) when running
outside CI.

## Prerequisites

- Terraform 1.10 or newer
- The `jkandler-terraform-state` S3 backend bucket
- AWS credentials with permission to manage AWS Budgets when bootstrapping
  or recovering outside GitHub Actions

## Deploy

```bash
export TF_VAR_alert_email="you@example.com"
terraform init
terraform plan
terraform apply
```

The S3 backend uses `aws-budget/terraform.tfstate` and native S3 lock
files.

The account-wide GitHub OIDC provider and the repository-bound plan/apply
roles are owned by `/home/julian/projects/bootstrap/repo-infra`. That
Terraform root runs only from a trusted local controller with a
short-lived administrative or bootstrap identity.

After bootstrapping or changing those roles, set these non-secret
repository variables under **Settings → Secrets and variables → Actions →
Variables** (`repo-infra`'s apply already sets `AWS_ROLE_ARN`/
`AWS_PLAN_ROLE_ARN`/`AWS_ACCOUNT_ID` automatically — `ALERT_EMAIL` comes
from this repository's `action_variables` entry in `config.yml`, also set
automatically):

| Repository variable | Value |
|---|---|
| `AWS_ROLE_ARN` | Set automatically by `repo-infra` |
| `AWS_PLAN_ROLE_ARN` | Set automatically by `repo-infra` |
| `AWS_ACCOUNT_ID` | Set automatically by `repo-infra` |
| `ALERT_EMAIL` | Set automatically by `repo-infra`, from `config.yml` |

## GitHub Actions credentials

Same as `dyndns`: no IAM user, no stored access keys. On `main`, GitHub
issues an OIDC identity token and exchanges it for a short-lived session
on the `aws-budget-github-actions` role. Pull requests get a separate
read-only session on `aws-budget-github-plan` for a speculative `terraform
plan` (skipped for forked PRs). After a merge, the apply workflow runs
`terraform apply` directly — this repository has no separate deploy step,
the Terraform apply *is* the deployment.

## Runner

Unlike `website`, this repository uses the self-hosted home runner
(`[self-hosted, home, debian]`), the same as `dyndns`. It was added to
`repo-infra`'s `config.yml` with `runner: true`; the runner itself is
registered via `home-infra`'s `scripts/sync_github_runner_repositories.py`
and the `github-runner.yml` playbook.

## Local validation

```bash
terraform fmt -check -recursive
terraform init -backend=false
terraform validate
```

GitHub Actions uses the same checks. Action dependencies are pinned to full
commit hashes rather than mutable version tags.
