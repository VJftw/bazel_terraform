"Unit tests for terraform_root implementation"

load("@bazel_skylib//lib:unittest.bzl", "asserts", "unittest")
load("//terraform/private:util.bzl", _latest_version_for_semver = "latest_version_for_semver")

def _latest_version_for_semver_test_impl(ctx):
    env = unittest.begin(ctx)
    asserts.equals(
        env,
        _latest_version_for_semver("1.4.3", ["1.4.3", "1.3.4", "1.4.4"]),
        "1.4.3",
    )
    asserts.equals(
        env,
        _latest_version_for_semver("1.3", ["1.4.3", "1.3.4", "1.4.4"]),
        "1.3.4",
    )
    asserts.equals(
        env,
        _latest_version_for_semver("1", ["1.4.3", "1.3.4", "1.4.4"]),
        "1.4.4",
    )
    return unittest.end(env)

latest_version_for_semver_test = unittest.make(_latest_version_for_semver_test_impl)
