# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [gcp-v1.0.0]
* Introducting a breaking change by updating the terraform required_providers block to the format supported for terraform versions >=0.13

## [gcp-v0.1.3]
* Update startup-script so that the upgrade command runs as an `at`. This is a bugfix in the situation that it upgrade `google-guest-agent` which would restart the startup-script and DNS Update + user creation will never happen.

## [gcp-v0.1.2]

* Update startup-script to not include a `dist-upgrade`
* Change the default compute-image project to `ubuntu-os-cloud` for more up to date images

## [gcp-v0.1.1]

* Fix GCP DNS registration script to remove old host records (#29)

## [0.1.0]

Initial release of the GCP bastion module.

