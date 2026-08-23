variable "monthly_limit_usd" {
  description = "Monthly cost budget limit, in USD (this account's actual billing currency)"
  type        = string
  default     = "10"
}

variable "alert_email" {
  description = "Email address to notify when the budget threshold is crossed"
  type        = string
  default     = "julian.kandler@outlook.com"
}
