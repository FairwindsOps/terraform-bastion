# Renders a user-creation snippet for each entry in var.additional_users using
# the built-in templatefile() function. The previous data "template_file"
# resource was deprecated and removed from the hashicorp/template provider.
locals {
  additional_user_rendered = [
    for u in var.additional_users : templatefile("${path.module}/additional_user.tmpl", {
      user_login = lookup(u, "login")
      # If gecos is not set, default to the user-name.
      user_gecos = lookup(u, "gecos", lookup(u, "login"))
      # If shell isn't set, default to bash.
      user_shell               = lookup(u, "shell", "/bin/bash")
      user_supplemental_groups = lookup(u, "supplemental_groups", "")
      user_authorized_keys     = lookup(u, "authorized_keys")
    })
  ]
}
