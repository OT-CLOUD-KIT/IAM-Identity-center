region = "us-east-1"

users = {
  alice = {
    user_name    = "alice"
    display_name = "Alice Johnson"
    first_name   = "Alice"
    last_name    = "Johnson"
    email        = "alice@example.com"
  }

  bob = {
    user_name    = "bob"
    display_name = "Bob Smith"
    first_name   = "Bob"
    last_name    = "Smith"
    email        = "bob@example.com"
  }
}

groups = {
  dev_team = {
    display_name = "Dev Team"
    description  = "Developers Group"
  }
  qa_team = {
    display_name = "QA Team"
  }
}

group_memberships = {
  alice_dev = { user = "alice", group = "dev_team" }
  bob_qa    = { user = "bob", group = "qa_team" }
}

permission_sets = {
  DevPowerUser = {
    description          = "Dev PowerUser permission set"
    session_duration = "PT1H"
    aws_managed_policies = ["arn:aws:iam::aws:policy/PowerUserAccess"]
    policy_template_file = "./policy-documents/ec2-read-only-access.tpl"
    policy_statement = <<JSON
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["s3:ListBucket"],
      "Resource": "*"
    }
  ]
}
JSON
  }

  QAReadOnly = {
    description          = "QA ReadOnly permission set"
    aws_managed_policies = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
    # no policy_statement
  }
}


account_assignments = {
  alice_dev_account = {
    principal_name = "alice"
    principal_type = "USER"
    permission_set = "DevPowerUser"
    account_id     = "339050856366"
  }

  dev_team_account = {
    principal_name = "dev_team"
    principal_type = "GROUP"
    permission_set = "DevPowerUser"
    account_id     = "339050856366"
  }
}

use_root_path_template = true
