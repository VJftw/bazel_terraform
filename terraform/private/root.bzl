"Implementation details for the root rule"

load("//terraform/private:util.bzl", "latest_version_for_semver", "maybe_create_windows_native_launcher_script")

_DOC = """
"""

_attrs = {
    "srcs": attr.label_list(
        allow_files = True,
    ),
    "var_files": attr.label_list(
        allow_files = True,
    ),
    "modules": attr.label_list(
        allow_files = False,
    ),
    "_venv_sh_tpl": attr.label(
        default = "venv.sh.tpl",
        allow_single_file = True,
    ),
    "_windows_constraint": attr.label(default = "@platforms//os:windows"),
    "terraform_version": attr.string(
        default = "",
        doc = "The version of Terraform to use. Partial versions may be specified to use the most recent semantic version.",
        mandatory = False,
    ),
}

def _impl(ctx):
    # [x] flatten srcs
    # [x] substitute bazel vars in files
    # [x] shift var files into auto-loaded var files

    # validate attrs
    # use first defined terraform from toolchain as default.
    terraform = ctx.toolchains["@bazel_terraform//terraform:terraform_toolchain_type"]

    if len(terraform.terraform_info.versions) < 1:
        fail("no terraform versions defined.")

    terraform_version = terraform.terraform_info.versions[0]
    if ctx.attr.terraform_version != "":
        terraform_version = latest_version_for_semver(
            ctx.attr.terraform_version,
            terraform.terraform_info.versions,
        )
        pass

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

    # TODO: It might be a "nice-to-have" to replace Bazel labels with their
    # paths, but that makes the Terraform configuration less portable and tied
    # to Bazel. Instead, I think it would be a better practice to enforce that
    # relative paths are used as described in the [Terraform documentation](https://developer.hashicorp.com/terraform/language/modules/sources#local-paths)
    # and just using Bazel for pre & post Terraform workflows.
    # for module in ctx.attr.modules:
    #     module_dir_from_root = paths.dirname(module.files.to_list()[0].tree_relative_path)
    #     substitutions[str(module.label)] = paths.join(".", ctx.bin_dir.path, module_dir_from_root)

    # for k, v in substitutions.items():
    #     # buildifier: disable=print
    #     print("replacing '{}' with '{}'".format(k, v))

    for src in ctx.files.srcs:
        out = ctx.actions.declare_file(src.basename)
        ctx.actions.expand_template(
            template = src,
            output = out,
            is_executable = False,
            substitutions = substitutions,
        )
        outs.append(out)

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

    executable = ctx.actions.declare_file("terraform_venv.sh")

    ctx.actions.expand_template(
        template = ctx.file._venv_sh_tpl,
        output = executable,
        is_executable = True,
        substitutions = {
            "{{launcher}}": terraform.terraform_info.launcher.short_path,
            "{{terraform_version}}": terraform_version,
            "{{root_path}}": ctx.files.srcs[0].short_path,
        },
    )

    runfiles = ctx.runfiles(files = outs)
    runfiles = runfiles.merge(terraform.default.default_runfiles)

    for module in ctx.attr.modules:
        runfiles = runfiles.merge(module[DefaultInfo].default_runfiles)

    return DefaultInfo(
        executable = maybe_create_windows_native_launcher_script(ctx, executable),
        files = depset(outs),
        runfiles = runfiles,
    )

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
    executable = True,
)
