# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [0.1.2]

### Changed

* The `bastion_name` module input is now used as the hostname for DNS registration, instead of `bastion`. After running `terrafomr apply` and updating SSH configurations to use the new hostname, please manually remove the Route53 record named `bastion`.

### Fixed

* The Route53 zone ID is now used by the DNS registration script instead of the zone name. This is more explicit, and handles cases where multiple (public and private) zones exist with the same name.

## [0.1.1]

### Added

* A new `remove_root_access` input to remove sudo access from the ubuntu user.

### Fixed

* The instructions for modifying ssh_config files to use the bastion are now more complete.

## [0.1.0]

Initial commit / release.
