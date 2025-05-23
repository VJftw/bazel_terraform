TerraformInfo = provider(
    doc = "Information about how to invoke the terraform executable.",
    fields = {
        "terraform_version_to_binary": "Terraform version to Executable Terraform Binary Labels",
    },
)

def _terraform_toolchain_impl(ctx):
    binaries = ctx.attr.terraform_version_to_binary.values()

    # binary_files = []
    # versions = []
    # for binary, version in ctx.attr.binary_versions.items():
    #     binary_files += binary.files.to_list()
    #     versions.append(version)

    # template_variables = platform_common.TemplateVariableInfo({
    #     "TERRAFORM_BIN": launcher.path,
    # })
    runfiles = []
    for b in binaries:
        runfiles += b[DefaultInfo].files.to_list()
    default = DefaultInfo(
        # files = depset(binaries),
        runfiles = ctx.runfiles(runfiles),
    )
    terraform_info = TerraformInfo(
        terraform_version_to_binary = ctx.attr.terraform_version_to_binary,
    )
    toolchain_info = platform_common.ToolchainInfo(
        terraform_info = terraform_info,
        # template_variables = template_variables,
        default = default,
    )
    return [
        default,
        toolchain_info,
        # template_variables,
    ]

terraform_toolchain = rule(
    implementation = _terraform_toolchain_impl,
    attrs = {
        "terraform_version_to_binary": attr.string_keyed_label_dict(
            doc = "Terraform version to Terraform Binary Labels",
            allow_files = True,
            # allow_rules = True,
            mandatory = True,
            cfg = "exec",
        ),
        # "launcher": attr.label(
        #     doc = "The Terraform binary.",
        #     mandatory = True,
        #     # allow_files = True,
        #     allow_single_file = True,
        #     executable = True,
        #     cfg = "exec",
        # ),
        # "binary_versions": attr.label_keyed_string_dict(
        #     mandatory = True,
        #     cfg = "exec",
        #     allow_files = True,
        # ),
    },
    doc = "Defines a terraform toolchain. See: https://docs.bazel.build/versions/main/toolchains.html#defining-toolchains.",
)
