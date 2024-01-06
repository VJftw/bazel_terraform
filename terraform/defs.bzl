"""
To load these rules, add this to the top of your `BUILD` file:

```starlark
load("@bazel_terraform//terraform:defs.bzl", ...)
```
"""

load("//terraform/private:module.bzl", _terraform_module = "terraform_module")
load("//terraform/private:root.bzl", _terraform_root = "terraform_root")

terraform_root_rule = _terraform_root
terraform_module_rule = _terraform_module

def terraform_root(name, srcs, **kwargs):
    """Macro wrapper around [terraform_root_rule](#terraform_root_rule).

    Args:
        name: name of resulting terraform_root rule.
        srcs: The srcs for the Terraform root.
        **kwargs: other named arguments to [terraform_push_rule](#terraform_push_rule) and
#             [common rule attributes](https://bazel.build/reference/be/common-definitions#common-attributes).
    """

    terraform_root_rule(
        name = name,
        srcs = srcs,
        **kwargs
    )

def terraform_module(name, srcs, **kwargs):
    """Macro wrapper around [terraform_module_rule](#terraform_module_rule).

    Args:
        name: name of resulting terraform_module rule.
        srcs: The srcs for the Terraform module.
        **kwargs: other named arguments to [terraform_push_rule](#terraform_push_rule) and
#             [common rule attributes](https://bazel.build/reference/be/common-definitions#common-attributes).
    """

    terraform_module_rule(
        name = name,
        srcs = srcs,
        **kwargs
    )
