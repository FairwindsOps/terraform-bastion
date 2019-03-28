data "template_file" "bastion_user_data" {
  template = "${file("${path.module}/bastion-userdata.tmpl")}"

  vars = {
    bastion_name                      = "${var.bastion_name}"
    infrastructure_bucket             = "${var.infrastructure_bucket}"
    infrastructure_bucket_bastion_key = "${var.infrastructure_bucket_bastion_key}"

    # THe ROute53 zone to add a `bastion` A record.
    zone_id = "${var.route53_zone_id}"

    # Configuration options for unattended upgrades, added to /etc/apt/apt.conf.d/50unattended-upgrades
    unattended_upgrade_reboot_time        = "${var.unattended_upgrade_reboot_time}"
    unattended_upgrade_email_recipient    = "${var.unattended_upgrade_email_recipient}"
    unattended_upgrade_additional_configs = "${var.unattended_upgrade_additional_configs}"

    remove_root_access = "${var.remove_root_access}"
  }
}

resource "aws_launch_configuration" "bastion" {
  # Generate a unique name for the Launch Configuration,
  # so the Auto Scaling Group can be updated without conflict before destroying the previous Launch Configuration.
  # Also see the related lifecycle block below.
  name_prefix = "${var.bastion_name}-"

  image_id      = "${data.aws_ami.ubuntu.id}"
  instance_type = "${var.instance_type}"

  iam_instance_profile        = "${aws_iam_instance_profile.bastion.name}"
  security_groups             = ["${aws_security_group.bastion_ssh.id}"]
  associate_public_ip_address = "true"

  user_data = "${data.template_file.bastion_user_data.rendered}"
  key_name  = "${aws_key_pair.bastion.id}"

  lifecycle {
    create_before_destroy = true

    # DO not recreate the Launch Configuration if a newer AMI becomes available.
    # `terrform taint` the Launch Configuration resource to force it to be recreated.
    # In the future we may want to also include user-data in this list.
    ignore_changes = ["image_id"]
  }
}
