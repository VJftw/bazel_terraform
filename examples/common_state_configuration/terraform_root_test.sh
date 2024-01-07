#!/usr/bin/env bash
set -Eeuo pipefail

"$1" "terraform init -backend=false
terraform validate

cat state-backend.tf

grep "$2-terraform.tfstate" state-backend.tf
"
