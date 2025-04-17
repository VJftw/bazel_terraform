#!/usr/bin/env bash
set -Eeuo pipefail

tf_root_venv="$PWD/$1"
opa_bin="$PWD/$2"
policy_rego_file="$PWD/$3"

"$tf_root_venv" "
terraform init -backend=false
terraform plan -refresh=false -out=tfplan
terraform show -json tfplan > tfplan.json
"

if "$tf_root_venv" "$opa_bin \
    eval \
    --fail-defined \
    --format pretty \
    --input tfplan.json \
    --data "$policy_rego_file" \
    "data.terraform.deny[_]"
"; then
	echo "expected OPA denial, but no errors were encountered"
	exit 1
fi
