variable "region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "users" {
  description = "List of users to create"
  type = map(object({
    user_name    = string
    display_name = string
    first_name   = string
    last_name    = string
    email        = string
  }))
  default = {}
}

variable "groups" {
  description = "List of groups to create"
  type = map(object({
    display_name = string
    description  = optional(string)
  }))
  default = {}
}

variable "group_memberships" {
  description = "Group memberships for users"
  type = map(object({
    user  = string
    group = string
  }))
  default = {}
}

variable "permission_sets" {
  description = "Permission sets with managed policies or inline/template policies"
  type = map(object({
    description          = optional(string)
    session_duration     = optional(string)
    relay_state          = optional(string)
    aws_managed_policies = optional(list(string))
    policy_statement     = optional(any)
    policy_template_file = optional(string)
    policy_template_vars = optional(map(any))
  }))
  default = {}
}

variable "account_assignments" {
  description = "Assignments of users/groups to accounts with permission sets"
  type = map(object({
    principal_name   = string
    principal_type   = string  # USER or GROUP
    permission_set   = string
    account_id       = string
  }))
  default = {}
}

variable "existing_users" {
  description = "Map of existing user_name to user_id"
  type        = map(string)
  default     = {}
}

variable "existing_groups" {
  description = "Map of existing group_name to group_id"
  type        = map(string)
  default     = {}
}

variable "use_root_path_template" {
  description = "Toggle to use root path for templatefile"
  type        = bool
  default     = false
}
