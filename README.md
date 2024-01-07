# Bazel rules for Hashicorp Terraform

## Design

This follows a similar pattern to my [Please Terraform rules](https://github.com/VJftw/please-terraform) repository which builds upon years of Terraform experience, with GitOps principals and enabling further declarative configuration beyond Terraform via a build system, in this case Bazel.

This repository and Bazel configuration is based upon [`bazel_terraform`](https://github.com/VJftw/bazel_terraform) which I've used to learn how to write a Bazel module.

### Features

- Multiple versions of Terraform simultaneously throughout your repositories.
  - This helps you migrate to/support newer Terraform versions if you have more than one `terraform_root` rule.
- Creating re-usable Terraform modules via the `terraform_module` rule.
- Using common state configuration to create unique Terraform states based on the Bazel Label for the `terraform_root` rule.
- Extending these rules to support declarative authentication.
- Extending these rules to support OPA policy evaluation on Terraform plans.

See the `./examples` folder for example uses of all of the above features.

#### TODO

- [ ] Downloading third-party modules via Bazel rules to add Bazel integrity checking.
- [ ] Downloading providers via Bazel rules to add Bazel integrity checking.
- [ ] Uploading `terraform_module` to a Terraform registry.

## Installation

See the install instructions on the release notes: <https://github.com/VJftw/bazel_terraform/releases>

To use a commit rather than a release, you can point at any SHA of the repo.

With bzlmod, you can use `archive_override` or `git_override`. For `WORKSPACE`, you modify the `http_archive` call; for example to use commit `abc123` with a `WORKSPACE` file:

1. Replace `url = "https://github.com/VJftw/bazel_terraform/releases/download/v0.1.0/bazel_terraform-v0.1.0.tar.gz"`
   with a GitHub-provided source archive like `url = "https://github.com/VJftw/bazel_terraform/archive/abc123.tar.gz"`
1. Replace `strip_prefix = "bazel_terraform-0.1.0"` with `strip_prefix = "bazel_terraform-abc123"`
1. Update the `sha256`. The easiest way to do this is to comment out the line, then Bazel will
   print a message with the correct value.

> Note that GitHub source archives don't have a strong guarantee on the sha256 stability, see
> <https://github.blog/2023-02-21-update-on-the-future-stability-of-source-code-archives-and-hashes>

## Usage

See `./examples` folder.
