"Implementation details for the module rule"

# load("//terraform/private:util.bzl", "maybe_create_windows_native_launcher_script")

_DOC = """
"""

_attrs = {
    "srcs": attr.label_list(
        allow_files = True,
    ),
    "modules": attr.label_list(
        allow_files = False,
    ),
    # "_terraform_sh_tpl": attr.label(
    #     default = "terraform.sh.tpl",
    #     allow_single_file = True,
    # ),
    "_windows_constraint": attr.label(default = "@platforms//os:windows"),
    # "toolchain": attr.label(
    #     allow_single_file = True,
    #     doc = "Label to an terraform_image or terraform_image_index",
    #     mandatory = True,
    # ),
}

def _impl(ctx):
    # [x] substitute bazel vars in files
    # TODO: colocate modules
    outs = []

    substitutions = {
        "{{label}}": str(ctx.label),
        "{{label.name}}": str(ctx.label.name),
        "{{label.package}}": str(ctx.label.package),
        "{{label.workspace_root}}": str(ctx.label.workspace_root),
        "{{workspace_name}}": str(ctx.workspace_name),
    }

    # Note: label.workspace_name is deprecated, but label.repo_name isn't always
    # set.
    if hasattr(ctx.label, "repo_name"):
        substitutions["{{label.repo_name}}"] = str(ctx.label.repo_name)
    elif hasattr(ctx.label, "workspace_name"):
        substitutions["{{label.repo_name}}"] = str(ctx.label.workspace_name)

    for module in ctx.attr.modules:
        # buildifier: disable=print
        print("replacing '{}' with '{}'".format(str(module.label), str(module.files.to_list()[0])))
        substitutions[str(module.label)] = str(module.files.to_list()[0].dirname)

    for src in ctx.files.srcs:
        out = ctx.actions.declare_file(src.basename)
        ctx.actions.expand_template(
            template = src,
            output = out,
            is_executable = False,
            substitutions = substitutions,
        )
        outs.append(out)

    runfiles = ctx.runfiles(files = outs)
    for module in ctx.attr.modules:
        runfiles = runfiles.merge(module[DefaultInfo].default_runfiles)

    return DefaultInfo(
        # executable = maybe_create_windows_native_launcher_script(ctx, executable),
        files = depset(outs),
        runfiles = runfiles,
    )

terraform_module_lib = struct(
    implementation = _impl,
    attrs = _attrs,
    # toolchains = [
    #     "@rules_terraform//terraform:terraform_toolchain_type",
    # ],
)

terraform_module = rule(
    doc = _DOC,
    implementation = terraform_module_lib.implementation,
    attrs = terraform_module_lib.attrs,
    # toolchains = terraform_module_lib.toolchains,
    # executable = True,
)
