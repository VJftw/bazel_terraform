"""
"""

load("@aspect_bazel_lib//lib:windows_utils.bzl", "create_windows_native_launcher_script")

def maybe_create_windows_native_launcher_script(ctx, shell_script):
    """Create a Windows Batch file to launch the given shell script.

    The rule should specify @bazel_tools//tools/sh:toolchain_type as a required toolchain.

    Args:
        ctx: Rule context
        shell_script: The bash launcher script

    Returns:
        A windows launcher script
    """
    if not ctx.target_platform_has_constraint(ctx.attr._windows_constraint[platform_common.ConstraintValueInfo]):
        return shell_script

    return create_windows_native_launcher_script(ctx, shell_script)

def latest_version_for_semver(semver, versions):
    """Returns the latest version from versions for the given semver.

    Args:
        semver: The semantic version partial to find the latest version for.
        versions: A list of available versions.

    Returns:
        The latest version for the given version or panics if none found.
    """
    semver_parts = semver.split(".")

    if len(semver_parts) == 3:
        # major.minor.patch given, return as it's a full semver already.
        if semver in versions:
            return semver
        else:
            fail("'{} is not available in toolchain ({})".format(semver, versions))

    filtered_versions = [version for version in versions if version.startswith(semver + ".")]

    if len(filtered_versions) < 1:
        fail("no versions available for {} in toolchain".format(semver))

    return _latest_version(filtered_versions)

def _latest_version(versions):
    version_tuples = []

    for version in versions:
        version_parts = version.split(".")
        version_tuples.append((
            version_parts[0],
            version_parts[1],
            version_parts[2],
        ))

    sorted_version_tuples = sorted(version_tuples, reverse = True)

    return ".".join(sorted_version_tuples[0])
