#!/usr/bin/env bash
set -Eeuo pipefail

terraform_version="$("$1" terraform --version)"
if [[ $terraform_version != *"v$2"* ]]; then
    echo "Expected Terraform v$2, got this output instead:"
    echo "$terraform_version"
    exit 1
fi

"$1" terraform init -backend=false

"$1" terraform validate
