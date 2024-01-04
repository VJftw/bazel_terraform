"""
To load these rules, add this to the top of your `BUILD` file:

```starlark
load("@rules_oci//oci:defs.bzl", ...)
```
"""

# load("@aspect_bazel_lib//lib:copy_file.bzl", "copy_file")
# load("@aspect_bazel_lib//lib:directory_path.bzl", "directory_path")
# load("@aspect_bazel_lib//lib:jq.bzl", "jq")
# load("@aspect_bazel_lib//lib:utils.bzl", "propagate_common_rule_attributes")
# load("@bazel_skylib//lib:types.bzl", "types")
# load("@bazel_skylib//rules:write_file.bzl", "write_file")
# load("//oci/private:image.bzl", _oci_image = "oci_image")
# load("//oci/private:image_index.bzl", _oci_image_index = "oci_image_index")
load("//terraform/private:module.bzl", _terraform_module = "terraform_module")
load("//terraform/private:root.bzl", _terraform_root = "terraform_root")
# load("//oci/private:tarball.bzl", _oci_tarball = "oci_tarball")

# oci_tarball_rule = _oci_tarball
# oci_image_rule = _oci_image
# oci_image_index = _oci_image_index
terraform_root_rule = _terraform_root
terraform_module_rule = _terraform_module

# def oci_image(name, labels = None, annotations = None, env = None, cmd = None, entrypoint = None, exposed_ports = None, **kwargs):
#     """Macro wrapper around [oci_image_rule](#oci_image_rule).

#     Allows labels and annotations to be provided as a dictionary, in addition to a text file.
#     See https://github.com/opencontainers/image-spec/blob/main/annotations.md

#     Label/annotation/env can by configured using either dict(key->value) or a file that contains key=value pairs
#     (one per line). The file can be preprocessed using (e.g. using `jq`) to supply external (potentially not
#     deterministic) information when running with `--stamp` flag.  See the example in
#     [/examples/labels/BUILD.bazel](https://github.com/bazel-contrib/rules_oci/blob/main/examples/labels/BUILD.bazel).

#     Produces a target `[name].digest`, whose default output is a file containing the sha256 digest of the resulting image.
#     This is similar to the same-named target created by rules_docker's `container_image` macro.

#     Args:
#         name: name of resulting oci_image_rule
#         labels: Labels for the image config. See documentation above.
#         annotations: Annotations for the image config. See documentation above.
#         env: Environment variables provisioned by default to the running container. See documentation above.
#         cmd: Command & argument configured by default in the running container. See documentation above.
#         entrypoint: Entrypoint configured by default in the running container. See documentation above.
#         exposed_ports: Exposed ports in the running container. See documentation above.
#         **kwargs: other named arguments to [oci_image_rule](#oci_image_rule) and
#             [common rule attributes](https://bazel.build/reference/be/common-definitions#common-attributes).
#     """
#     forwarded_kwargs = propagate_common_rule_attributes(kwargs)

#     if types.is_dict(annotations):
#         annotations_label = "_{}_write_annotations".format(name)
#         write_file(
#             name = annotations_label,
#             out = "_{}.annotations.txt".format(name),
#             content = ["{}={}".format(key, value) for (key, value) in annotations.items()],
#             **forwarded_kwargs
#         )
#         annotations = annotations_label

#     if types.is_dict(labels):
#         labels_label = "_{}_write_labels".format(name)
#         write_file(
#             name = labels_label,
#             out = "_{}.labels.txt".format(name),
#             content = ["{}={}".format(key, value) for (key, value) in labels.items()],
#             **forwarded_kwargs
#         )
#         labels = labels_label

#     if types.is_dict(env):
#         env_label = "_{}_write_env".format(name)
#         write_file(
#             name = env_label,
#             out = "_{}.env.txt".format(name),
#             content = ["{}={}".format(key, value) for (key, value) in env.items()],
#             **forwarded_kwargs
#         )
#         env = env_label

#     if types.is_dict(env):
#         env_label = "_{}_write_env".format(name)
#         write_file(
#             name = env_label,
#             out = "_{}.env.txt".format(name),
#             content = ["{}={}".format(key, value) for (key, value) in env.items()],
#             **forwarded_kwargs
#         )
#         env = env_label

#     if types.is_list(cmd):
#         cmd_label = "_{}_write_cmd".format(name)
#         write_file(
#             name = cmd_label,
#             out = "_{}.cmd.txt".format(name),
#             content = [",".join(cmd)],
#             **forwarded_kwargs
#         )
#         cmd = cmd_label

#     if types.is_list(entrypoint):
#         entrypoint_label = "_{}_write_entrypoint".format(name)
#         write_file(
#             name = entrypoint_label,
#             out = "_{}.entrypoint.txt".format(name),
#             content = [",".join(entrypoint)],
#             **forwarded_kwargs
#         )
#         entrypoint = entrypoint_label

#     if types.is_list(exposed_ports):
#         exposed_ports_label = "_{}_write_exposed_ports".format(name)
#         write_file(
#             name = exposed_ports_label,
#             out = "_{}.exposed_ports.txt".format(name),
#             content = [",".join(exposed_ports)],
#             **forwarded_kwargs
#         )
#         exposed_ports = exposed_ports_label

#     oci_image_rule(
#         name = name,
#         annotations = annotations,
#         labels = labels,
#         env = env,
#         cmd = cmd,
#         entrypoint = entrypoint,
#         exposed_ports = exposed_ports,
#         **kwargs
#     )

#     # `oci_image_rule` produces a directory as default output.
#     # Label for the [name]/index.json file
#     directory_path(
#         name = "_{}_index_json".format(name),
#         directory = name,
#         path = "index.json",
#         **forwarded_kwargs
#     )

#     copy_file(
#         name = "_{}_index_json_cp".format(name),
#         src = "_{}_index_json".format(name),
#         out = "_{}_index.json".format(name),
#         **forwarded_kwargs
#     )

#     # Matches the [name].digest target produced by rules_docker container_image
#     jq(
#         name = name + ".digest",
#         args = ["--raw-output"],
#         srcs = ["_{}_index.json".format(name)],
#         filter = """.manifests[0].digest""",
#         out = name + ".json.sha256",  # path chosen to match rules_docker for easy migration
#         **forwarded_kwargs
#     )

def terraform_root(name, srcs, **kwargs):
    """Macro wrapper around [terraform_root_rule](#terraform_root_rule).

    Args:
        name: name of resulting terraform_root rule.
        srcs: The srcs for the Terraform root.
        **kwargs: other named arguments to [oci_push_rule](#oci_push_rule) and
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
        **kwargs: other named arguments to [oci_push_rule](#oci_push_rule) and
#             [common rule attributes](https://bazel.build/reference/be/common-definitions#common-attributes).
    """

    terraform_module_rule(
        name = name,
        srcs = srcs,
        **kwargs
    )

# def oci_push(name, remote_tags = None, **kwargs):
#     """Macro wrapper around [oci_push_rule](#oci_push_rule).

#     Allows the remote_tags attribute to be a list of strings in addition to a text file.

#     Args:
#         name: name of resulting oci_push_rule
#         remote_tags: a list of tags to apply to the image after pushing,
#             or a label of a file containing tags one-per-line.
#             See [stamped_tags](https://github.com/bazel-contrib/rules_oci/blob/main/examples/push/stamp_tags.bzl)
#             as one example of a way to produce such a file.
#         **kwargs: other named arguments to [oci_push_rule](#oci_push_rule) and
#             [common rule attributes](https://bazel.build/reference/be/common-definitions#common-attributes).
#     """
#     forwarded_kwargs = propagate_common_rule_attributes(kwargs)

#     if types.is_list(remote_tags):
#         tags_label = "_{}_write_tags".format(name)
#         write_file(
#             name = tags_label,
#             out = "_{}.tags.txt".format(name),
#             content = remote_tags,
#             **forwarded_kwargs
#         )
#         remote_tags = tags_label

#     oci_push_rule(
#         name = name,
#         remote_tags = remote_tags,
#         **kwargs
#     )

# def oci_tarball(name, repo_tags = None, **kwargs):
#     """Macro wrapper around [oci_tarball_rule](#oci_tarball_rule).

#     Allows the repo_tags attribute to be a list of strings in addition to a text file.

#     Args:
#         name: name of resulting oci_tarball_rule
#         repo_tags: a list of repository:tag to specify when loading the image,
#             or a label of a file containing tags one-per-line.
#             See [stamped_tags](https://github.com/bazel-contrib/rules_oci/blob/main/examples/push/stamp_tags.bzl)
#             as one example of a way to produce such a file.
#         **kwargs: other named arguments to [oci_tarball_rule](#oci_tarball_rule) and
#             [common rule attributes](https://bazel.build/reference/be/common-definitions#common-attributes).
#     """
#     forwarded_kwargs = propagate_common_rule_attributes(kwargs)

#     if types.is_list(repo_tags):
#         tags_label = "_{}_write_tags".format(name)
#         write_file(
#             name = tags_label,
#             out = "_{}.tags.txt".format(name),
#             content = repo_tags,
#             **forwarded_kwargs
#         )
#         repo_tags = tags_label

#     oci_tarball_rule(
#         name = name,
#         repo_tags = repo_tags,
#         **kwargs
#     )
