variable "monthly_limit_usd" {
  description = "Monthly cost budget limit, in USD (this account's actual billing currency)"
  type        = string
  default     = "10"
}

variable "alert_email" {
  description = "Email address to notify when the budget threshold is crossed"
  type        = string
  # No default -- this repo is public. Supplied via TF_VAR_alert_email from
  # a repo-infra action_variables entry, same pattern as dyndns/website's
  # ROUTE53_ZONE_ID, so the address doesn't end up committed to git history.
}
