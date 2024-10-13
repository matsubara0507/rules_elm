load(
    ":toolchain.bzl",
    "DEFAULT_ELM_REPOSITORY",
    "DEFAULT_VERSION",
    "DEFAULT_TEST_VERSION",
    register_elm_toolchains = "toolchains",
)

def _find_modules(module_ctx):
    root = None
    our_module = None
    for mod in module_ctx.modules:
        if mod.is_root:
            root = mod
        if mod.name == "rules_elm":
            our_module = mod
    if root == None:
        root = our_module
    if our_module == None:
        fail("Unable to find rules_elm module")

    return root, our_module

def _elm_impl(module_ctx):
    root, rules_elm = _find_modules(module_ctx)
    toolchains = root.tags.toolchain or rules_elm.tags.toolchain
    for toolchain in toolchains:
        register_elm_toolchains(
            name = toolchain.name,
            version = toolchain.version,
            test_version = toolchain.test_version,
            register = False,
        )

elm = module_extension(
    implementation = _elm_impl,
    tag_classes = {
        "toolchain": tag_class(attrs = {
            "name": attr.string(
                default = DEFAULT_ELM_REPOSITORY,
            ),
            "version": attr.string(
                default = DEFAULT_VERSION,
            ),
            "test_version": attr.string(
                default = DEFAULT_TEST_VERSION,
            ),
        }),
    },
)
