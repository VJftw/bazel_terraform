"Implementation details for the root rule"

load("@bazel_skylib//lib:paths.bzl", "paths")
load("//terraform/private:util.bzl", "latest_version_for_semver")

_DOC = """
"""

_attrs = {
    "srcs": attr.label_list(
        allow_files = True,
        mandatory = True,
    ),
    "var_files": attr.label_list(
        allow_files = True,
        mandatory = False,
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
    "terraform_version": attr.string(
        default = "",
        doc = " ".join("""
The version of Terraform to use. Partial versions may be specified to use the
most recent semantic version.
        """.splitlines()).strip(" "),
        mandatory = False,
    ),
    "terraform_tool": attr.label(
        executable = True,
        cfg = "exec",
        allow_files = True,
        default = Label("@bazel_terraform//terraform/tools/bazel_terraform:bazel_terraform"),
    ),
}

def _impl(ctx):
    # validate attrs
    # use first defined terraform from toolchain as default.
    terraform = ctx.toolchains["@bazel_terraform//terraform:terraform_toolchain_type"]

    if len(terraform.terraform_info.terraform_version_to_binary.keys()) < 1:
        fail("no terraform versions defined.")

    terraform_version = terraform.terraform_info.terraform_version_to_binary.keys()[0]
    if ctx.attr.terraform_version != "":
        terraform_version = latest_version_for_semver(
            ctx.attr.terraform_version,
            terraform.terraform_info.terraform_version_to_binary.keys(),
        )
        pass

    #
    out_dir = ctx.actions.declare_directory(ctx.label.name)
    ctx.actions.run(
        inputs = ctx.files.var_files,
        outputs = [out_dir],
        arguments = [out_dir.path] + [f.path for f in ctx.files.var_files],
        executable = ctx.executable.terraform_tool,
    )

    # ctx.actions.run_shell(outputs = [out_dir], command = "mkdir -p " + out_dir.path)
    outs = [out_dir]
    substitutions = _get_substitutions(ctx)
    # for i, src in enumerate(ctx.files.var_files):
    #     basename_parts = src.basename.split(".")
    #     basename_no_ext = basename_parts[0]
    #     ext = "auto." + ".".join(basename_parts[1:len(basename_parts)])
    #     out = "{}-{}.{}".format(i, basename_no_ext, ext)

    # copy_file(out, src, paths.join(out_dir.path, out), False, False)
    # out = ctx.actions.declare_file(paths.join(out_dir.path, out))
    # ctx.actions.expand_template(
    #     template = src,
    #     output = out,
    #     is_executable = False,
    #     substitutions = substitutions,
    # )
    # outs.append(out)

    #
    # outs = []

    # substitutions = _get_substitutions(ctx)
    # outs += _autoload_var_files(ctx, substitutions)
    # outs += _add_srcs_with_substitutions(ctx, substitutions)
    # outs += _add_modules(ctx)

    # meta = ctx.actions.declare_file(".bazel_terraform.json")
    # ctx.actions.write(
    #     output = meta,
    #     content = json.encode({
    #         "terraform_version": terraform_version,
    #     }),
    #     is_executable = False,
    # )
    # outs.append(meta)

    # executable = ctx.actions.declare_file("terraform_venv.sh")

    # ctx.actions.expand_template(
    #     template = ctx.file._venv_sh_tpl,
    #     output = executable,
    #     is_executable = True,
    #     substitutions = {
    #         "{{launcher}}": terraform.terraform_info.launcher.short_path,
    #         "{{terraform_version}}": terraform_version,
    #         "{{root_path}}": ctx.files.srcs[0].short_path,
    #     },
    # )

    runfiles = ctx.runfiles(files = outs)
    runfiles = runfiles.merge(terraform.default.default_runfiles)

    # for module in ctx.attr.modules:
    #     runfiles = runfiles.merge(module[DefaultInfo].default_runfiles)

    return DefaultInfo(
        # executable = executable,
        files = depset(outs),
        runfiles = runfiles,
    )

def _get_substitutions(ctx):
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

    return substitutions

def _autoload_var_files(ctx, substitutions):
    outs = []
    for i, src in enumerate(ctx.files.var_files):
        basename_parts = src.basename.split(".")
        basename_no_ext = basename_parts[0]
        ext = "auto." + ".".join(basename_parts[1:len(basename_parts)])
        out = "{}-{}.{}".format(i, basename_no_ext, ext)

        out = ctx.actions.declare_file(out)
        ctx.actions.expand_template(
            template = src,
            output = out,
            is_executable = False,
            substitutions = substitutions,
        )
        outs.append(out)
    return outs

def _add_srcs_with_substitutions(ctx, substitutions):
    outs = []
    for src in ctx.files.srcs:
        out = ctx.actions.declare_file(src.basename)
        ctx.actions.expand_template(
            template = src,
            output = out,
            is_executable = False,
            substitutions = substitutions,
        )
        outs.append(out)
    return outs

def _add_modules(ctx):
    outs = []
    for module_name, target in ctx.attr.modules.items():
        mod_dir = paths.join("modules", module_name)
        for f in target[DefaultInfo].files.to_list():
            this_f = ctx.actions.declare_file(paths.join(mod_dir, f.basename))
            ctx.actions.expand_template(
                template = f,
                output = this_f,
            )
            outs.append(this_f)
    return outs

terraform_root_lib = struct(
    implementation = _impl,
    attrs = _attrs,
    toolchains = [
        "@bazel_terraform//terraform:terraform_toolchain_type",
    ],
)

terraform_root = rule(
    doc = _DOC,
    implementation = terraform_root_lib.implementation,
    attrs = terraform_root_lib.attrs,
    toolchains = terraform_root_lib.toolchains,
    # executable = True,
)
