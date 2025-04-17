#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail

# Set by GH actions, see
# https://docs.github.com/en/actions/learn-github-actions/environment-variables#default-environment-variables
TAG=${GITHUB_REF_NAME}
# The prefix is chosen to match what GitHub generates for source archives
PREFIX="bazel_terraform-${TAG:1}"
ARCHIVE="bazel_terraform-$TAG.tar.gz"
git archive --format=tar --prefix=${PREFIX}/ ${TAG} | gzip >$ARCHIVE
SHA=$(shasum -a 256 $ARCHIVE | awk '{print $1}')

cat <<EOF
## Using bzlmod with Bazel 6 or later:

1. Add \`common --enable_bzlmod\` to \`.bazelrc\`.

2. Add to your \`MODULE.bazel\` file:

\`\`\`starlark
bazel_dep(name = "bazel_terraform", version = "${TAG:1}")

terraform = use_extension("@bazel_terraform//terraform:extensions.bzl", "terraform")

# Add the Terraform versions you'd like
terraform.toolchains(terraform_version = "1.6.6")
terraform.toolchains(terraform_version = "1.6.4", sha256_by_platform = {"linux_amd64": "my-sha256-sum"})

use_repo(terraform, "terraform_terraform_toolchains")
register_toolchains("@terraform_terraform_toolchains//:all")
\`\`\`
EOF
