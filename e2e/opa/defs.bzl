"""
Extend @bazel_terraform defs and use these instead.
"""

load("@bazel_terraform//terraform:defs.bzl", upstream_terraform_root_rule = "terraform_root")

def terraform_root(name, srcs, **kwargs):
    """Macro wrapper around [terraform_root_rule](#terraform_root_rule).

    Args:
        name: name of resulting terraform_root rule.
        srcs: The srcs for the Terraform root.
        **kwargs: other named arguments to [terraform_push_rule](#terraform_push_rule) and
#             [common rule attributes](https://bazel.build/reference/be/common-definitions#common-attributes).
    """

    upstream_terraform_root_rule(
        name = name,
        srcs = srcs,
        **kwargs
    )

    native.sh_test(
        name = "{}_plan_test".format(name),
        srcs = ["//:terraform_plan.sh"],
        args = [
            "$(location :{})".format(name),
            "$(location @opa//file)",
            "$(location //:policy.rego)",
        ],
        data = [
            name,
            "@opa//file",
            "//:policy.rego",
        ],
    )
