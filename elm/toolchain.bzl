load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive", "http_file")

DEFAULT_VERSION = "0.19.1"

ELM_COMPILER_BINDIST = \
    {
        "0.19.1": {
            "linux": "e44af52bb27f725a973478e589d990a6428e115fe1bb14f03833134d6c0f155c",
            "mac": "05289f0e3d4f30033487c05e689964c3bb17c0c48012510dbef1df43868545d1",
            "windows": "d1bf666298cbe3c5447b9ca0ea608552d750e5d232f9845c2af11907b654903b",
        },
        "0.19.0": {
            "linux": "d359adbee89823c641cda326938708d7227dc79aa1f162e0d8fe275f182f528a",
            "mac": "f1fa4dd9021e94c5a58b2be8843e3329095232ee3bd21a23524721a40eaabd35",
            "windows": "0e27d80537418896cf98326224159a45b6d36bf08e608e3a174ab6d2c572c5ae",
        },
    }


def _elm_compiler_build_file_context(os):
    """
exports_files(["elm"])
elm_toolchain(name = {}_info, elm = ":elm")
    """.format(os)

def _elm_compiler_impl(ctx):
    os = ctx.attr.os
    version = ctx.attr.version
    file_name = "elm-{}".format(os)
    ctx.download(
        url = "https://github.com/elm/compiler/releases/download/{}/binary-for-{}-64-bit.gz".format(version, os),
        sha256 = ctx.attr.checksum,
        output = file_name + ".gz",
    )
    ctx.execute([ctx.which("gzip"), "-d", file_name + ".gz"])
    ctx.execute([ctx.which("chmod"), "+x", file_name])
    ctx.file(
        "BUILD",
        executable = False,
        content = """
load("@rules_elm//elm:toolchain.bzl", "elm_toolchain")
exports_files(["elm-{os}"])
elm_toolchain(name = "{os}_info", elm = ":elm-{os}")
        """.format(os = os),
    )


_elm_compiler = repository_rule(
    _elm_compiler_impl,
    local = False,
    attrs = {
        "os": attr.string(),
        "version": attr.string(),
        "checksum": attr.string(),
    },
)

def _elm_compiler_toolchain_impl(ctx):
    exec_constraints = [{
        "linux": "@platforms//os:linux",
        "mac": "@platforms//os:osx",
        "windows": "@platforms//os:windows",
    }.get(ctx.attr.os)]
    ctx.file(
        "BUILD",
        executable = False,
        content = """
toolchain(
    name = "toolchain",
    toolchain_type = "@rules_elm//elm:toolchain",
    toolchain = "@{bindist_name}//:{os}_info",
    exec_compatible_with = {exec_constraints},
    target_compatible_with = {target_constraints},
)
        """.format(
            os = ctx.attr.os,
            bindist_name = ctx.attr.bindist_name,
            exec_constraints = exec_constraints,
            target_constraints = exec_constraints,
        ),
    )

_elm_compiler_toolchain = repository_rule(
    _elm_compiler_toolchain_impl,
    local = False,
    attrs = {
        "bindist_name": attr.string(),
        "os": attr.string(),
    },
)

def rules_elm_toolchains(version = DEFAULT_VERSION):
    if not ELM_COMPILER_BINDIST.get(version):
        fail("Binary distribution of Elm {} is not available.".format(version))
    for os, checksum in ELM_COMPILER_BINDIST.get(version).items():
        bindist_name = "rules_elm_compiler_{}".format(os)
        toolchain_name = bindist_name + "-toolchain"
        _elm_compiler(name = bindist_name, os = os, version = version, checksum = checksum)
        _elm_compiler_toolchain(name = toolchain_name, bindist_name = bindist_name, os = os)
        native.register_toolchains("@{}//:toolchain".format(toolchain_name))

def _elm_toolchain_impl(ctx):
    return [platform_common.ToolchainInfo(
        elm = ctx.file.elm,
    )]

elm_toolchain = rule(
    _elm_toolchain_impl,
    attrs = {
        "elm": attr.label(
            allow_single_file = True,
            mandatory = True,
        ),
    },
)
