output "created_users" {
  description = "List of created Identity Store Users"
  value       = { for k, v in aws_identitystore_user.users : k => v.user_id }
}

output "created_groups" {
  description = "List of created Identity Store Groups"
  value       = { for k, v in aws_identitystore_group.groups : k => v.group_id }
}

output "group_memberships" {
  description = "Group memberships"
  value       = { for k, v in aws_identitystore_group_membership.group_memberships : k => v.id }
}

output "permission_sets" {
  description = "Created Permission Sets"
  value       = { for k, v in aws_ssoadmin_permission_set.permission_sets : k => v.arn }
}

output "account_assignments" {
  description = "Account Assignments"
  value       = { for k, v in aws_ssoadmin_account_assignment.assignments : k => v.id }
}
