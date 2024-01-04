"""This module implements the language-specific toolchain rule."""

TerraformInfo = provider(
    doc = "Information about how to invoke the terraform executables.",
    fields = {
        "launcher": "Executable terraform binary",
        "versions": "versions",
    },
)

def _terraform_toolchain_impl(ctx):
    launcher = ctx.executable.launcher

    binary_files = []
    versions = []
    for binary, version in ctx.attr.binary_versions.items():
        binary_files += binary.files.to_list()
        versions.append(version)

    template_variables = platform_common.TemplateVariableInfo({
        "TERRAFORM_BIN": launcher.path,
    })
    default = DefaultInfo(
        files = depset([launcher] + binary_files),
        runfiles = ctx.runfiles(files = [launcher] + binary_files),
    )
    terraform_info = TerraformInfo(
        launcher = launcher,
        versions = versions,
    )
    toolchain_info = platform_common.ToolchainInfo(
        terraform_info = terraform_info,
        template_variables = template_variables,
        default = default,
    )
    return [
        default,
        toolchain_info,
        template_variables,
    ]

terraform_toolchain = rule(
    implementation = _terraform_toolchain_impl,
    attrs = {
        "launcher": attr.label(
            doc = "The target that supports launching different versions of downloaded Terraform binaries.",
            mandatory = True,
            # allow_files = True,
            allow_single_file = True,
            executable = True,
            cfg = "exec",
        ),
        "binary_versions": attr.label_keyed_string_dict(
            mandatory = True,
            cfg = "exec",
            allow_files = True,
        ),
    },
    doc = "Defines a terraform toolchain. See: https://docs.bazel.build/versions/main/toolchains.html#defining-toolchains.",
)
