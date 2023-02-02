# This template data source is created for each user specified in the additional_external_users module input.
# The below template(s) will be rendered in the bastion-userdata.tmpl template.
locals {
  additional-external-users-script-content = format("%s%s", "#!/bin/bash \n\n", join("\n", templatefile("${path.module}/additional_external_user.tmpl", {

    # The additional_external_users input is a list of maps.
    user_login = lookup(var.additional_external_users[count.index], "login")

    # If gecos is nset, default to the user-name.
    user_gecos = lookup(var.additional_external_users[count.index], "gecos", lookup(var.additional_external_users[count.index], "login"))

    # If shell is isn't set, default to bash.
    user_shell               = lookup(var.additional_external_users[count.index], "shell", "/bin/bash")
    user_supplemental_groups = lookup(var.additional_external_users[count.index], "supplemental_groups", "")
    user_authorized_keys     = lookup(var.additional_external_users[count.index], "authorized_keys")
    }
  )))
  additional-external-users-script-md5 = md5(local.additional-external-users-script-content)
}

resource "aws_s3_bucket_object" "additional-external-users-script" {
  bucket  = local.infrastructure_bucket.id
  key     = "${var.infrastructure_bucket_bastion_key}/additional-external-users"
  content = local.additional-external-users-script-content
  etag    = md5(local.additional-external-users-script-content)
}
