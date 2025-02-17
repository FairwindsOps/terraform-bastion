# Terraform AWS Bastion Module

This module manages an Amazon Web Services bastion EC2 instance and its Auto Scaling Group, Instance Profile / Role, CloudWatch Log Group, Security Group, and SSH Key Pair. The Auto Scaling Group will recreate the bastion if there is an issue with the EC2 instance or the availability zone where it is running.

The EC2 UserData assumes the Ubuntu operating system, which is configured as follows:

* Packages are updated, and the bastion is rebooted if required.
* If SSH hostkeys are present in the configurable S3 bucket and path, they are copied to the bastion to retain its previous SSH identity. If there are no host keys in S3, the current keys are copied there.
* The [CloudWatch Logs Agent][] is installed and configured to ship logs from these files:
	* `/var/log/syslog`
	* `/var/log/auth.log`
* A host record, named using the `bastion_name` module input,  is added to a configurable Route53 DNS zone for the current public IP address of the bastion. This happens via a script configured to run each time the bastion boots.
* Automatic updates are configured, using a configurable time to reboot, and the email address to receive errors.
* By default sudo access is removed from the ubuntu user unless the `remove_root_access` input is set to "false."
* Additional EC2 User Data can be executed, for one-off configuration not included in this module.
* Additional users can be created and populated with their own `authorized_keys` file.

## Using The Bastion
### SSH Access to Kubernetes Nodes

To proxy SSH connections to Kubernetes nodes through the bastion, add configuration like the following to the top of the `ssh_config` file. Replace the following information with your own values:

* `domain.com` with the same **domain name** that was specified as a Route53 zone ID in the instance of the bastion Terraform module. This is the domain name where the bastions host record will have been created during boot.
* `/path/to/ssh/private/key` with the path to your SSH private key file.
* `172.20.*.*` with the VPC CIDR.

```
# Define options to be used when connecting to the bastion.
host bastion.domain.com
  IdentityFile /path/to/ssh/private/key
  IdentitiesOnly yes
  User ubuntu

# Use the bastion to proxy SSH connections to IPs in the VPC
# You can also add a DNS wildcard to the end of the next line
# if you use DNS resolution to access Kubernetes nodes.
host 172.20.*.*
  ProxyCommand ssh -i /path/to/ssh/private/key ubuntu@bastion.domain.com -W %h:%p
```

You can now SSH directly to IP addresses within `172.20.0.0/16`, and your connection will be proxied through the bastion.


### Accessing a Private Kubernetes API

#### Non-EKS Clusters (like kops)

You can proxy access to a private Kubernetes API through the bastion, instead of using a VPN.

Run the following to forward connections from port 8443 on your workstation, to a private Kubernetes API, - replace `api.clustername.domain.com` with your private API hostname, and `bastion.domain.com` with the hostname of your bastion:

```
ssh -L 8443:api.clustername.domain.com:443 ubuntu@bastion.domain.com
```

In another terminal tab, edit your KubeConfig and replace `api.clustername.domain.com` with `127.0.0.1:8443` in the `server` line for your private cluster.

With the above, as long as the SSH proxy connection remains active, you can use `kubectl` to access your private Kubernetes cluster. Close the SSH connection in the other terminal tab to stop proxying to the private API.

#### EKS Clusters

Certificates for EKS API endpoints will not be valid for the `127.0.0.1` address in the above example. You can use a [SOCKS5 Proxy](https://kubernetes.io/docs/tasks/extend-kubernetes/socks5-proxy-access-api/) to access these clusters.

### Use Sshuttle to get a VPN-like Experience

The [sshuttle](https://sshuttle.readthedocs.io/en/stable/) tool uses NAT redirect firewall rules to proxy access to a network over a bastion. This is useful to connect to multiple ports on multiple hosts without maintaining a lot of SSH forwarding.

The bastion already has Python installed, which sshuttle requires to be on the bastion. Once you have [installed sshuttle](https://sshuttle.readthedocs.io/en/stable/installation.html) on your workstation, use the following to redirect access to your VPC CIDR over the bastion - replacing `bastion.domain.com` with your bastion hostname, and `172.20.0.0/16` with your VPC CIDR:

```
sshuttle -r ubuntu@bastion.domain.com 172.20.0.0/16
```

You can now access your private Kubernetes API using the internal API hostname in the KubeConfig, and SSH directly to Kubernetes nodes without any proxy configuration defined in your `ssh_config` file.

Press CTRL-c to kill sshuttle when you are done with the proxy. There are many useful sshuttle command-line options, such as running in the background, and specifying the CIDR to redirect in a file.


[CloudWatch Logs Agent]: https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Install-CloudWatch-Agent.html

## Using The Terraform Module

See the file [example-usage](./example-usage) for an example of how to use this module. Below are the available module inputs:

### Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 0.13)

- <a name="requirement_aws"></a> [aws](#requirement\_aws) (>=2.30.0)

### Providers

The following providers are used by this module:

- <a name="provider_aws"></a> [aws](#provider\_aws) (>=2.30.0)

- <a name="provider_template"></a> [template](#provider\_template)

### Modules

No modules.

### Resources

The following resources are used by this module:

- [aws_autoscaling_group.bastion](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/autoscaling_group) (resource)
- [aws_cloudwatch_log_group.bastion](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) (resource)
- [aws_iam_instance_profile.bastion](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) (resource)
- [aws_iam_role.bastion_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) (resource)
- [aws_iam_role_policy.bastion_logging](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) (resource)
- [aws_iam_role_policy.bastion_route53](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) (resource)
- [aws_iam_role_policy.bastion_s3](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) (resource)
- [aws_key_pair.bastion](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair) (resource)
- [aws_launch_template.bastion](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/launch_template) (resource)
- [aws_s3_bucket_object.additional-external-users-script](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_object) (resource)
- [aws_security_group.bastion_ssh](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) (resource)
- [aws_security_group_rule.bastion_egress](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) (resource)
- [aws_security_group_rule.bastion_ssh](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) (resource)
- [aws_ami.ubuntu](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) (data source)
- [aws_s3_bucket.infrastructure_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/s3_bucket) (data source)
- [template_file.additional_external_user](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) (data source)
- [template_file.additional_user](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) (data source)
- [template_file.bastion_user_data](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) (data source)

### Required Inputs

The following input variables are required:

#### <a name="input_infrastructure_bucket"></a> [infrastructure\_bucket](#input\_infrastructure\_bucket)

Description: An S3 bucket to store data that should persist on the bastion when it is recycled by the Auto Scaling Group, such as SSH host keys. This can be set in the environment via `TF_VAR_infrastructure_bucket`

Type: `any`

#### <a name="input_route53_zone_id"></a> [route53\_zone\_id](#input\_route53\_zone\_id)

Description: ID of the ROute53 zone for the bastion to add its host record.

Type: `any`

#### <a name="input_unattended_upgrade_email_recipient"></a> [unattended\_upgrade\_email\_recipient](#input\_unattended\_upgrade\_email\_recipient)

Description: An email address where unattended upgrade errors should be emailed. THis sets the option in /etc/apt/apt.conf.d/50unattended-upgrades

Type: `any`

#### <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id)

Description: The VPC ID where the bastion and its security group will be created. This must match subnet IDs specified in the `vpc_subnet_ids` input.

Type: `any`

#### <a name="input_vpc_subnet_ids"></a> [vpc\_subnet\_ids](#input\_vpc\_subnet\_ids)

Description: A list of subnet IDs where the Auto Scaling Group can place the bastion.

Type: `list`

### Optional Inputs

The following input variables are optional (have default values):

#### <a name="input_additional_external_users"></a> [additional\_external\_users](#input\_additional\_external\_users)

Description: Additional users to be created on the bastion. Works the same as additional\_users, but adds users via a separate systemd unit file. Specify users as a list of maps. See an example in the `example-usage` file. Required map keys are `login` (user name) and `authorized_keys`. Optional map keys are `gecos` (full name), `supplemental_groups` (comma-separated), and `shell`. The authorized\_keys will be output to ~/.ssh/authorized\_keys using printf - multiple keys can be specified by including \n in the string.

Type: `list`

Default: `[]`

#### <a name="input_additional_user_data"></a> [additional\_user\_data](#input\_additional\_user\_data)

Description: Content to be appended to UserData, which is run the first time the bastion EC2 boots.

Type: `string`

Default: `""`

#### <a name="input_additional_users"></a> [additional\_users](#input\_additional\_users)

Description: Additional users to be created on the bastion. Specify users as a list of maps. See an example in the `example-usage` file. Required map keys are `login` (user name) and `authorized_keys`. Optional map keys are `gecos` (full name), `supplemental_groups` (comma-separated), and `shell`. The authorized\_keys will be output to ~/.ssh/authorized\_keys using printf - multiple keys can be specified by including \n in the string.

Type: `list`

Default: `[]`

#### <a name="input_ami_filter_value"></a> [ami\_filter\_value](#input\_ami\_filter\_value)

Description: The filter path for the AMI.

Type: `string`

Default: `"ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"`

#### <a name="input_ami_owner_id"></a> [ami\_owner\_id](#input\_ami\_owner\_id)

Description: The ID of the AMI's owner in AWS. The default is Canonical.

Type: `string`

Default: `"099720109477"`

#### <a name="input_ami_owner_id_govcloud"></a> [ami\_owner\_id\_govcloud](#input\_ami\_owner\_id\_govcloud)

Description: The ID of the AMI's owner in AWS GovCloud. This value is used automatically if the module's `arn_prefix` input variable is anything other than `arn:aws`. The default is Canonical.

Type: `string`

Default: `"513442679011"`

#### <a name="input_arn_prefix"></a> [arn\_prefix](#input\_arn\_prefix)

Description: The prefix to use for AWS ARNs.

Type: `string`

Default: `"arn:aws"`

#### <a name="input_bastion_name"></a> [bastion\_name](#input\_bastion\_name)

Description: The name of the bastion EC2 instance, DNS hostname, CloudWatch Log Group, and the name prefix for other related resources.

Type: `string`

Default: `"ro-bastion"`

#### <a name="input_custom_image_id"></a> [custom\_image\_id](#input\_custom\_image\_id)

Description: Custom image ID. Use if you prefer a specific image to a standard Ubuntu image.

Type: `string`

Default: `""`

#### <a name="input_encrypt_root_volume"></a> [encrypt\_root\_volume](#input\_encrypt\_root\_volume)

Description: If true, encrypt the root ebs volume of the bastion

Type: `bool`

Default: `true`

#### <a name="input_extra_asg_tags"></a> [extra\_asg\_tags](#input\_extra\_asg\_tags)

Description: Extra tags for the bastion autoscaling group

Type: `list`

Default: `[]`

#### <a name="input_infrastructure_bucket_bastion_key"></a> [infrastructure\_bucket\_bastion\_key](#input\_infrastructure\_bucket\_bastion\_key)

Description: The key; sub-directory in $infrastructure\_bucket where the bastion will be allowed to read and write. Do not specify a trailing slash. This allows sharing an S3 bucket among multiple invocations of this module.

Type: `string`

Default: `"bastion"`

#### <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type)

Description: The EC2 instance type of the bastion.

Type: `string`

Default: `"t3.micro"`

#### <a name="input_log_retention"></a> [log\_retention](#input\_log\_retention)

Description: The number of days to retain logs in the CloudWatch Log Group.

Type: `string`

Default: `"60"`

#### <a name="input_remove_root_access"></a> [remove\_root\_access](#input\_remove\_root\_access)

Description: Whether to remove root access from the ubuntu user. Set this to yes|true|1 to remove root access, or anything else to retain it.

Type: `string`

Default: `"true"`

#### <a name="input_root_volume_type"></a> [root\_volume\_type](#input\_root\_volume\_type)

Description: The root volume type for the bastion instance

Type: `string`

Default: `"gp3"`

#### <a name="input_ssh_cidr_blocks"></a> [ssh\_cidr\_blocks](#input\_ssh\_cidr\_blocks)

Description: A list of CIDRs allowed to SSH to the bastion. Override the module default by specifying an empty list, []

Type: `list(string)`

Default:

```json
[
  "0.0.0.0/0"
]
```

#### <a name="input_ssh_public_key_file"></a> [ssh\_public\_key\_file](#input\_ssh\_public\_key\_file)

Description: The content of an existing SSH public key file, that will be used to create an AWS SSH Key Pair. Yes, this input has an unfortunate name.

Type: `string`

Default: `""`

#### <a name="input_unattended_upgrade_additional_configs"></a> [unattended\_upgrade\_additional\_configs](#input\_unattended\_upgrade\_additional\_configs)

Description: Additional configuration lines to add to /etc/apt/apt.conf.d/50unattended-upgrades

Type: `string`

Default: `""`

#### <a name="input_unattended_upgrade_reboot_time"></a> [unattended\_upgrade\_reboot\_time](#input\_unattended\_upgrade\_reboot\_time)

Description: The time that the bastion should reboot, when necessary, after an an unattended upgrade. This sets the option in /etc/apt/apt.conf.d/50unattended-upgrades

Type: `string`

Default: `"21:30"`

### Outputs

The following outputs are exported:

#### <a name="output_autoscaling_group_arn"></a> [autoscaling\_group\_arn](#output\_autoscaling\_group\_arn)

Description: The ARN of the autoscaling group

#### <a name="output_autoscaling_group_id"></a> [autoscaling\_group\_id](#output\_autoscaling\_group\_id)

Description: The ID of the autoscaling group

#### <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id)

Description: The ID of the bastion security group

## Contributing

We are happy to share this internal module with the community. We appreciate suggestions for improvement, and recommend starting by opening an issue. Please see [contributing.md](../CONTRIBUTING.md) for details.

## Design Considerations

The [design document](../DESIGN.md) describes the goals and vision for this project. 
