"""Repository rules for fetching external tools"""

load("//terraform/private:toolchains_repo.bzl", "PLATFORMS", "toolchains_repo")
load("//terraform/private:versions.bzl", "TERRAFORM_VERSIONS")

TERRAFORM_BUILD_TMPL = """\
# Generated by terraform/repositories.bzl
load("@bazel_skylib//rules:native_binary.bzl", "native_binary")
load("@rules_terraform//terraform:toolchain.bzl", "terraform_toolchain")

native_binary(
    name = "launcher",
    out = "{launcher_out}",
    src = "launcher.inner.sh",
)

terraform_toolchain(
    name = "terraform_toolchain",
    launcher = ":launcher",
    binary_versions = {terraform_binary_versions}
)
"""

TERRAFORM_LAUNCHER = """\
#!/usr/bin/env bash
# This script launches the binary for the given Terraform version.
set -Eeuo pipefail

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Add `terraform` binary from toolchain to PATH.
export PATH="$SCRIPT_DIR/terraform_$1:$PATH"

shift

# execute user-provided commands. This may be a shell (`bash`/`sh`) which would
# inherit the PATH variable with the `terraform` binary from the toolchain.
"$@"
"""

def _terraform_repo_impl(repository_ctx):
    platform = repository_ctx.attr.platform

    terraform_version_config = repository_ctx.attr.terraform_version_config

    terraform_binary_versions = {}
    for terraform_version, config_json in terraform_version_config.items():
        config = json.decode(config_json)
        url = "https://releases.hashicorp.com/terraform/{version}/terraform_{version}_{platform}.zip".format(
            version = terraform_version,
            platform = platform,
        )
        windows_bin_name = "terraform_{}/terraform.exe".format(terraform_version)
        unix_bin_name = "terraform_{}/terraform".format(terraform_version)

        sha256 = ""
        if platform in config["sha256_by_platform"]:
            sha256 = config["sha256_by_platform"][platform]
        elif terraform_version in TERRAFORM_VERSIONS and platform in TERRAFORM_VERSIONS[terraform_version]:
            sha256 = TERRAFORM_VERSIONS[terraform_version][platform]
        else:
            fail("missing sha256 for Terraform {}, Platform: {}", terraform_version, platform)

        repository_ctx.download_and_extract(
            url = url,
            sha256 = sha256,
            rename_files = {
                "terraform.exe": windows_bin_name,
                "terraform": unix_bin_name,
            },
        )
        binary = windows_bin_name if platform.startswith("windows_") else unix_bin_name

        terraform_binary_versions[binary] = terraform_version

    repository_ctx.file(
        "launcher.inner.sh",
        TERRAFORM_LAUNCHER,
    )

    repository_ctx.file(
        "BUILD.bazel",
        TERRAFORM_BUILD_TMPL.format(
            launcher_out = "launcher.exe" if platform.startswith("windows_") else "launcher.sh",
            terraform_binary_versions = terraform_binary_versions,
        ),
    )

terraform_repositories = repository_rule(
    _terraform_repo_impl,
    doc = "Fetch external tools needed for terraform toolchain",
    attrs = {
        "terraform_version_config": attr.string_dict(mandatory = True),
        "platform": attr.string(mandatory = True, values = PLATFORMS.keys()),
    },
)

# Wrapper macro around everything above, this is the primary API
def terraform_register_toolchains(name, terraform_version_config, register = True):
    """Convenience macro for users which does typical setup.

    - create a repository for each built-in platform like "container_linux_amd64" -
      this repository is lazily fetched when terraform is needed for that platform.
    - create a repository exposing toolchains for each platform like "container_platforms"
    - register a toolchain pointing at each platform
    Users can avoid this macro and do these steps themselves, if they want more control.
    Args:
        name: base name for all created repos, like "container7"
        terraform_version_config: passed to each terraform_repositories call
        register: whether to call through to native.register_toolchains.
            Should be True for WORKSPACE users, but false when used under bzlmod extension
    """

    # locate the config file on the host
    # terraform_auth_config_locator(name = "terraform_auth_config")

    terraform_toolchain_name = "{name}_terraform_toolchains".format(name = name)

    for platform in PLATFORMS.keys():
        terraform_repositories(
            name = "{name}_terraform_{platform}".format(name = name, platform = platform),
            platform = platform,
            terraform_version_config = terraform_version_config,
        )

        if register:
            native.register_toolchains("@{}//:{}_toolchain".format(terraform_toolchain_name, platform))

    toolchains_repo(
        name = terraform_toolchain_name,
        toolchain_type = "@rules_terraform//terraform:terraform_toolchain_type",
        # avoiding use of .format since {platform} is formatted by toolchains_repo for each platform.
        toolchain = "@%s_terraform_{platform}//:terraform_toolchain" % name,
    )
