#!/usr/bin/env bash
set -Eeuo pipefail

"$1" terraform init -backend=false

"$1" terraform plan -refresh=false -out=tfplan

if ! grep module_a tfplan; then
    echo "missing module_a in Terraform plan"
fi

if ! grep module_b tfplan; then
    echo "missing module_b in Terraform plan"
fi
