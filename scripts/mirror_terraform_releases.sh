#!/usr/bin/env bash
# This script produces a mirror of Terraform release information to directly
# replace the `./terraform/private/versions.bzl` file.
set -Eeuo pipefail

# https://www.hashicorp.com/.well-known/pgp-key.txt
hashicorp_pgp_key_file="$1"

HASHICORP_RELEASES_BASE_URL="https://releases.hashicorp.com"
# From: https://www.hashicorp.com/trust/security
KEY_ID="72D7468F"

export GNUPGHOME="$(mktemp -d)"
chmod 0700 "$GNUPGHOME"
gpg --import "$hashicorp_pgp_key_file"
echo -e "5\nquit\n" | gpg --command-fd 0 --expert --edit-key $KEY_ID trust

mapfile -t terraform_release_url_dirs < \
    <(
        curl -sL "${HASHICORP_RELEASES_BASE_URL}/terraform" \
        | grep "terraform_" \
        | cut -f2 -d \" \
        | xargs printf "${HASHICORP_RELEASES_BASE_URL}%s\n"
    )

json="{}"

for terraform_release_url in "${terraform_release_url_dirs[@]}"; do
    version="$(echo "$terraform_release_url" | rev | cut -f2 -d/ | rev)"
    >&2 echo "processing Terraform $version..."

    json="$(echo "$json" | jq --arg version "$version" '.[$version] = {}')"

    sha256sums_url="${terraform_release_url}terraform_${version}_SHA256SUMS"
    sha256sums_sig_url="${terraform_release_url}terraform_${version}_SHA256SUMS.sig"
    >&2 curl -sL "${sha256sums_url}" -o "terraform_${version}_SHA256SUMS"
    >&2 curl -sL "${sha256sums_sig_url}" -o "terraform_${version}_SHA256SUMS.sig"
    if ! gpg --verify "terraform_${version}_SHA256SUMS.sig" "terraform_${version}_SHA256SUMS" 2>&1 | grep "Good signature" > /dev/null; then
        echo "could not find good signature for terraform_${version}_SHA256SUMS.sig"
        exit 1
    fi

    mapfile -t sha256sum_lines < "terraform_${version}_SHA256SUMS"

    for sha256sum_line in "${sha256sum_lines[@]}"; do
        sha256sum="$(echo "$sha256sum_line" | cut -f1 -d" ")"
        platform="$(echo "$sha256sum_line" | awk '{ print $2 }' | rev | cut -f1-2 -d_ | rev | cut -f1 -d.)"

        json="$(echo "$json" | jq \
            --arg version "$version" \
            --arg platform "$platform" \
            --arg sha256sum "$sha256sum" \
            '.[$version][$platform] = $sha256sum')"
    done
done

cat <<EOF
"""
GENERATED by \`bazel run //scripts/mirror_terraform_releases\`
Mirror of Terraform Release info.
"""

TERRAFORM_VERSIONS = $json
EOF
