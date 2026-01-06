load("//elm:toolchain.bzl", "DEFAULT_TEST_VERSION", "DEFAULT_VERSION", "ELM_COMPILER_BINDIST", "elm_compiler_repo", "elm_compiler_toolchain_repo")

_toolchains_tag = tag_class(
    attrs = {
        "version": attr.string(),
        "test_version": attr.string(),
    },
)

def _toolchains_impl(ctx):
    tag = None
    for mod in ctx.modules:
        for t in mod.tags.toolchains:
            tag = t

    version = tag.version if tag and tag.version else DEFAULT_VERSION
    test_version = tag.test_version if tag and tag.test_version else DEFAULT_TEST_VERSION.get(version)

    if not ELM_COMPILER_BINDIST.get(version):
        fail("Binary distribution of Elm {} is not available.".format(version))

    for os, checksum in ELM_COMPILER_BINDIST.get(version).items():
        bindist_name = "rules_elm_compiler_{}".format(os)
        toolchain_name = bindist_name + "-toolchain"
        elm_compiler_repo(
            name = bindist_name,
            os = os,
            version = version,
            checksum = checksum,
            test_version = test_version,
        )
        elm_compiler_toolchain_repo(
            name = toolchain_name,
            bindist_name = bindist_name,
            os = os,
        )

toolchains = module_extension(
    implementation = _toolchains_impl,
    tag_classes = {"toolchains": _toolchains_tag},
)
