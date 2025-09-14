"Implementation details for the module rule"

_DOC = """
"""

_attrs = {
    "srcs": attr.label_list(
        allow_files = True,
        mandatory = True,
    ),
    "modules": attr.label_list(
        allow_files = False,
        default = [],
        doc = " ".join("""
Modules to be placed in `./modules/`.
        """.splitlines()).strip(" "),
        mandatory = False,
        # TODO: Must meet terraform_module.
        # providers = [],
    ),
    "terraform_tool": attr.label(
        executable = True,
        cfg = "exec",
        allow_files = True,
        default = Label("@bazel_terraform//terraform/tools/bazel_terraform:bazel_terraform"),
    ),
}

def _impl(ctx):
    # [x] substitute bazel vars in files
    # TODO: colocate modules
    out_dir = ctx.actions.declare_directory(ctx.label.name)
    terraform_tool_args = ["--out_dir=" + out_dir.path]
    terraform_tool_args += ["--src=" + f.path for f in ctx.files.srcs]
    terraform_tool_args += ["--module=" + f.path for f in ctx.files.modules]
    ctx.actions.run(
        executable = ctx.executable.terraform_tool,
        inputs = ctx.files.srcs + ctx.files.modules,
        outputs = [out_dir],
        arguments = terraform_tool_args,
    )

    outs = [out_dir]

    substitutions = {
        "{{label}}": str(ctx.label),
        "{{label.name}}": str(ctx.label.name),
        "{{label.package}}": str(ctx.label.package),
        "{{label.workspace_root}}": str(ctx.label.workspace_root),
        "{{workspace_name}}": str(ctx.workspace_name),
    }

    # Note: label.workspace_name is deprecated, but label.repo_name isn't always
    # set.
    # if hasattr(ctx.label, "repo_name"):
    #     substitutions["{{label.repo_name}}"] = str(ctx.label.repo_name)
    # elif hasattr(ctx.label, "workspace_name"):
    #     substitutions["{{label.repo_name}}"] = str(ctx.label.workspace_name)

    # for module in ctx.attr.modules:
    #     # buildifier: disable=print
    #     print("replacing '{}' with '{}'".format(str(module.label), str(module.files.to_list()[0])))
    #     substitutions[str(module.label)] = str(module.files.to_list()[0].dirname)

    # for src in ctx.files.srcs:
    #     out = ctx.actions.declare_file(src.basename)
    #     ctx.actions.expand_template(
    #         template = src,
    #         output = out,
    #         is_executable = False,
    #         substitutions = substitutions,
    #     )
    #     outs.append(out)

    runfiles = ctx.runfiles(files = outs)
    for module in ctx.attr.modules:
        runfiles = runfiles.merge(module[DefaultInfo].default_runfiles)

    return DefaultInfo(
        files = depset(outs),
        runfiles = runfiles,
    )

terraform_module_lib = struct(
    implementation = _impl,
    attrs = _attrs,
)

terraform_module = rule(
    doc = _DOC,
    implementation = terraform_module_lib.implementation,
    attrs = terraform_module_lib.attrs,
)
