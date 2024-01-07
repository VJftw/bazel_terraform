#!/usr/bin/env bash
set -Eeuo pipefail

tf_root_venv="$PWD/$1"
auth_target="$2"

cat <<EOF

Authenticating to "$auth_target"...

For this Example, this actually does nothing but in a real-world scenario, this
could authenticate you to your desired AWS account, e.g.

$ aws sts assume-role --role-arn <arn for $auth_target>

EOF

# Then run Terraform plan etc.
"$tf_root_venv" "
terraform init -backend=false
terraform plan -refresh=false
"
