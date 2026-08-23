output "budget_name" {
  description = "Name of the created AWS Budget"
  value       = aws_budgets_budget.monthly_cost_alert.name
}

output "monthly_limit" {
  description = "Configured monthly cost limit"
  value       = "${var.monthly_limit_usd} ${aws_budgets_budget.monthly_cost_alert.limit_unit}"
}
