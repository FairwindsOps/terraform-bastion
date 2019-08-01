# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [0.3.3]
### Added

* Added inputs for the ARN prefix to include support for GovCloud.

## [0.3.2]
### Added

* Added inputs for the AMI owner and filter, so that a different AMI could be used. Keep in mind that the UserData is strongly biased toward an Ubuntu AMI.

## [0.3.1]
### Changed
* Ignore tags on the SSH security group.
* Fixing apt install prompt issues.  Fixes #6

## [0.3.0]
### Added

* An `additional_users` input creates SSH users on the bastion. The available per-user fields are login, gecos (full name), shell, supplemental groups, and SSH authorized\_keys.
* A `additional_user-data` input adds content toward the end of EC2 User Data. The additional User Data is executed before users specified in `additional_users` are added.

### Changed

* The Auto Scaling Group (and its bastion EC2) will now be recreated when there is an update to the Launch Configuration. The new Auto Scaling Group will be created before the current one is deleted. Previously the EC2 remained untouched after a Launch Configuration update, which left its recycling to operator discretion.

### Fixed

* The Launch Configuration lifecycle block incorrectly specified ignoring `image_id`, and a new AMI caused an update to the Launch Configuration. A new AMI will now be ignored. Recycling the EC2 due to a new AMI should be less necessary as this module enables automatic Ubuntu updates.

## [0.2.0]

### Changed

* The `bastion_name` module input is now used as the hostname for DNS registration, instead of `bastion`. After running `terraform apply` and updating SSH configurations to use the new hostname, please manually remove the Route53 record named `bastion`.

### Fixed

* The Route53 zone ID is now used by the DNS registration script instead of the zone name. This is more explicit, and handles cases where multiple (public and private) zones exist with the same name.

## [0.1.1]

### Added

* A new `remove_root_access` input to remove sudo access from the ubuntu user.

### Fixed

* The instructions for modifying ssh_config files to use the bastion are now more complete.

## [0.1.0]

Initial commit / release.
