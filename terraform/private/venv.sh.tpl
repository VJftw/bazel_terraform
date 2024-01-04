#!/usr/bin/env bash
set -Eeuo pipefail

launcher="$PWD/{{launcher}}"

# Go to terraform_root directory
cd "$(dirname "{{root_path}}")"

# execute user-provided commands with Terraform launcher.
"$launcher" "{{terraform_version}}" "$@"
