terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# ------------------------------------------------------------------------
# Data sources to discover IAM Identity Center instance and identity store
# ------------------------------------------------------------------------
data "aws_ssoadmin_instances" "this" {}

locals {
  identity_center_instance_arn = data.aws_ssoadmin_instances.this.arns[0]
  identity_store_id            = data.aws_ssoadmin_instances.this.identity_store_ids[0]
}

# ------------------------------------------------------------------------
# Dynamic User Creation
# ------------------------------------------------------------------------
resource "aws_identitystore_user" "users" {
  for_each = var.users

  identity_store_id = local.identity_store_id
  display_name      = each.value.display_name
  user_name         = each.value.user_name

  name {
    given_name  = each.value.first_name
    family_name = each.value.last_name
  }

  emails {
    value = each.value.email
  }
}

# ------------------------------------------------------------------------
# Dynamic Group Creation
# ------------------------------------------------------------------------
resource "aws_identitystore_group" "groups" {
  for_each = var.groups

  identity_store_id = local.identity_store_id
  display_name      = each.value.display_name
  description       = lookup(each.value, "description", null)
}

# ------------------------------------------------------------------------
# Dynamic Group Memberships
# ------------------------------------------------------------------------
resource "aws_identitystore_group_membership" "group_memberships" {
  for_each = var.group_memberships

  identity_store_id = local.identity_store_id

  group_id = (
    contains(keys(aws_identitystore_group.groups), each.value.group)
    ? aws_identitystore_group.groups[each.value.group].group_id
    : var.existing_groups[each.value.group]
  )

  member_id = (
    contains(keys(aws_identitystore_user.users), each.value.user)
    ? aws_identitystore_user.users[each.value.user].user_id
    : var.existing_users[each.value.user]
  )
}

# ------------------------------------------------------------------------
# Permission Set Creation
# ------------------------------------------------------------------------
resource "aws_ssoadmin_permission_set" "permission_sets" {
  for_each = var.permission_sets

  instance_arn     = local.identity_center_instance_arn
  name             = each.key
  description      = lookup(each.value, "description", null)
  session_duration = lookup(each.value, "session_duration", "PT1H")
  relay_state      = lookup(each.value, "relay_state", null)
}

# ------------------------------------------------------------------------
# Attach AWS Managed Policies
# ------------------------------------------------------------------------
resource "aws_ssoadmin_managed_policy_attachment" "managed_policy" {
  for_each = {
    for ps_name, ps_data in var.permission_sets :
    ps_name => ps_data if length(lookup(ps_data, "aws_managed_policies", [])) > 0
  }

  instance_arn       = local.identity_center_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.permission_sets[each.key].arn
  managed_policy_arn = each.value.aws_managed_policies[0]
}

# ------------------------------------------------------------------------
# Attach Inline Policies (supports inline JSON or template files)
# ------------------------------------------------------------------------




resource "aws_ssoadmin_permission_set_inline_policy" "inline_policy" {
  for_each = {
    for ps_name, ps_data in var.permission_sets :
    ps_name => ps_data
    if (
      (contains(keys(ps_data), "policy_statement") && ps_data.policy_statement != null && length(keys(ps_data.policy_statement)) > 0) ||
      (contains(keys(ps_data), "policy_template_file") && ps_data.policy_template_file != null)
    )
  }

  instance_arn       = local.identity_center_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.permission_sets[each.key].arn

 inline_policy = (
  lookup(each.value, "policy_template_file", null) != null ?
    templatefile(
      "${path.root}/${each.value.policy_template_file}",
      coalesce(each.value.policy_template_vars, {})
    ) :
    (
      each.value.policy_statement != null ?
      jsonencode(each.value.policy_statement) :
      null  
    )
)

}


# ------------------------------------------------------------------------
# Account Assignment Creation
# ------------------------------------------------------------------------
resource "aws_ssoadmin_account_assignment" "assignments" {
  for_each = var.account_assignments

  instance_arn       = local.identity_center_instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.permission_sets[each.value.permission_set].arn
  principal_type     = each.value.principal_type

  principal_id = (
    each.value.principal_type == "USER" ?
    (
      contains(keys(aws_identitystore_user.users), each.value.principal_name) ?
      aws_identitystore_user.users[each.value.principal_name].user_id :
      var.existing_users[each.value.principal_name]
    ) :
    (
      contains(keys(aws_identitystore_group.groups), each.value.principal_name) ?
      aws_identitystore_group.groups[each.value.principal_name].group_id :
      var.existing_groups[each.value.principal_name]
    )
  )

  target_type = "AWS_ACCOUNT"
  target_id   = each.value.account_id
    depends_on = [
    aws_ssoadmin_permission_set.permission_sets,
    aws_ssoadmin_permission_set_inline_policy.inline_policy
  ]

}
