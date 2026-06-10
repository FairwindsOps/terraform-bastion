# Renders a user-creation snippet for each entry in var.additional_external_users
# using the built-in templatefile() function. The previous data "template_file"
# resource was deprecated and removed from the hashicorp/template provider.
locals {
  additional_external_user_rendered = [
    for u in var.additional_external_users : templatefile("${path.module}/additional_external_user.tmpl", {
      user_login = lookup(u, "login")
      # If gecos is not set, default to the user-name.
      user_gecos = lookup(u, "gecos", lookup(u, "login"))
      # If shell isn't set, default to bash.
      user_shell               = lookup(u, "shell", "/bin/bash")
      user_supplemental_groups = lookup(u, "supplemental_groups", "")
      user_authorized_keys     = lookup(u, "authorized_keys")
    })
  ]

  additional-external-users-script-content = format("%s%s", "#!/bin/bash \n\n", join("\n", local.additional_external_user_rendered))
  additional-external-users-script-md5     = md5(local.additional-external-users-script-content)
}

resource "aws_s3_object" "additional-external-users-script" {
  bucket  = local.infrastructure_bucket.id
  key     = "${var.infrastructure_bucket_bastion_key}/additional-external-users"
  content = local.additional-external-users-script-content
  etag    = md5(local.additional-external-users-script-content)
}
