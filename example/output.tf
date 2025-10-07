output "identity_center_users" {
  description = "Created users from Identity Center module"
  value       = module.identity_center.created_users
}

output "identity_center_groups" {
  description = "Created groups from Identity Center module"
  value       = module.identity_center.created_groups
}

output "identity_center_group_memberships" {
  description = "Group memberships"
  value       = module.identity_center.group_memberships
}

output "identity_center_permission_sets" {
  description = "Created Permission Sets"
  value       = module.identity_center.permission_sets
}

output "identity_center_account_assignments" {
  description = "Account Assignments"
  value       = module.identity_center.account_assignments
}
