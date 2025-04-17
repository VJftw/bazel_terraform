#!/usr/bin/env bash
#
# Shows an end-to-end workflow for linting without failing the build.
# This is meant to mimic the behavior of the `bazel lint` command that you'd have
# by using the Aspect CLI [lint command](https://docs.aspect.build/cli/commands/aspect_lint).
#
# To make the build fail when a linter warning is present, run with `--fail-on-violation`.
# To auto-fix violations, run with `--fix` (or `--fix --dry-run` to just print the patches)
#
# NB: this is an example of code you could paste into your repo, meaning it's userland
# and not a supported public API of rules_lint. It may be broken and we don't make any
# promises to fix issues with using it.
set -Eeuo pipefail

buildevents=$(mktemp)
# This is a JQ filter - we want to output $ext without expansion.
# shellcheck disable=SC2016
filter='.namedSetOfFiles | values | .files[] | select(.name | endswith($ext)) | ((.pathPrefix | join("/")) + "/" + .name)'

if [ "$#" -eq 0 ]; then
	echo "usage: lint.sh [target pattern...]"
	exit 1
fi

unameOut="$(uname -s)"
case "${unameOut}" in
Linux*) machine=Linux ;;
Darwin*) machine=Mac ;;
CYGWIN*) machine=Windows ;;
MINGW*) machine=Windows ;;
MSYS_NT*) machine=Windows ;;
*) machine="UNKNOWN:${unameOut}" ;;
esac

args=()
if [ "$machine" == "Windows" ]; then
	# avoid missing linters on windows platform
	args=("--aspects=$(echo //tools/lint:linters.bzl%{flake8,pmd,ruff,vale,clang_tidy} | tr ' ' ',')")
else
	args=("--aspects=$(echo //tools/lint:linters.bzl%shellcheck | tr ' ' ',')")
fi

# NB: perhaps --remote_download_toplevel is needed as well with remote execution?
args+=(
	# Allow lints of code that fails some validation action
	# See https://github.com/aspect-build/rules_ts/pull/574#issuecomment-2073632879
	"--norun_validations"
	"--build_event_json_file=$buildevents"
	"--output_groups=rules_lint_human"
	"--remote_download_regex='.*AspectRulesLint.*'"
	# Include fix patches
	"--@aspect_rules_lint//lint:fix"
	"--output_groups=rules_lint_patch"
)

# Run linters
cd "$BUILD_WORKSPACE_DIRECTORY"
set -x
bazel build "${args[@]}" "$@"
set +x

# TODO: Maybe this could be hermetic with bazel run @aspect_bazel_lib//tools:jq or sth
# jq on windows outputs CRLF which breaks this script. https://github.com/jqlang/jq/issues/92
valid_reports=$(jq --arg ext .out --raw-output "$filter" "$buildevents" | tr -d '\r')

echo "$valid_reports"

# Show the results.
while IFS= read -r report; do
	# Exclude coverage reports, and check if the output is empty.
	if [[ "$report" == *coverage.dat ]] || [[ ! -s "$report" ]]; then
		# Report is empty. No linting errors.
		continue
	fi
	echo "From ${report}:"
	cat "${report}"
	echo
done <<<"$valid_reports"

fix="${LINT_FIX_MODE:-print}"

if [ -n "$fix" ]; then
	valid_patches=$(jq --arg ext .patch --raw-output "$filter" "$buildevents" | tr -d '\r')
	while IFS= read -r patch; do
		# Exclude coverage, and check if the patch is empty.
		if [[ "$patch" == *coverage.dat ]] || [[ ! -s "$patch" ]]; then
			# Patch is empty. No linting errors.
			continue
		fi

		case "$fix" in
		"print")
			echo "From ${patch}:"
			cat "${patch}"
			echo
			;;
		"patch")
			patch -p1 <"${patch}"
			;;
		*)
			echo "ERROR: unknown fix type $fix"
			exit 1
			;;
		esac

	done <<<"$valid_patches"
fi
