module "identity_center" {
  source = "../"

  region                = var.region
  users                 = var.users
  groups                = var.groups
  group_memberships     = var.group_memberships
  permission_sets       = var.permission_sets
  account_assignments   = var.account_assignments
  existing_users        = var.existing_users
  existing_groups       = var.existing_groups
  use_root_path_template = var.use_root_path_template
}