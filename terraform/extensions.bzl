"extensions for bzlmod"

load(":repositories.bzl", "terraform_register_toolchains")

toolchains = tag_class(attrs = {
    "terraform_version": attr.string(doc = "Explicit version of Terraform.", mandatory = True),
    "sha256_by_platform": attr.string_dict(doc = "Override expected sha256 hash per platform.", mandatory = False),
})

def _terraform_extension(module_ctx):
    for mod in module_ctx.modules:
        terraform_version_config = {}
        for toolchains in mod.tags.toolchains:
            terraform_version_config[toolchains.terraform_version] = json.encode({
                "sha256_by_platform": toolchains.sha256_by_platform,
            })

        terraform_register_toolchains(
            name = "terraform",
            terraform_version_config = terraform_version_config,
            register = False,
        )

terraform = module_extension(
    implementation = _terraform_extension,
    tag_classes = {
        # "pull": pull,
        "toolchains": toolchains,
    },
)
