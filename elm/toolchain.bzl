load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive", "http_file")

DEFAULT_VERSION = "0.19.1"

DEFAULT_TEST_VERSION = \
    {
        "0.19.1": "3.0",
    }

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

ELM_TEST_BINDIST = \
    {
        "1.2.1": {
            "linux": "6e5759f832a5e025898c9306ba47b2f9ed7f0c371dc69bd16c15c7ed8bfb1501",
            "mac": "890c45a7eda24fd13169d349af9c835ee3ed04974eec36953baba5aefc3628a8",
            "windows": "26add13880af484a47cd182547f41370d3bfca812a7cc9e3db6f41ce13b7fc40",
        },
        "2.0.2": {
            "linux": "ede814df1dec5781e00dccba56ad38d901af2c8be55a33bd31e0fbcf2b5ee771",
            "mac": "d24d73edea77d607c488d8aecf083e09b6e3873d71b109269ab38b35dfd60236",
            "windows": "5baa282339b8e36e7a0b2ff87733fd2f01dd8b31dedaa12332ad24f706a91ba4",
        },
        "3.0": {
            "linux": "c72702d32a2a9e051667febeeef486a1794798d0770be1a9da95895e10b6db0f",
            "mac": "41e2be1d77fb587ac1336f4b8822feb3b914eff7364715f6cac0bc4a90c0948a",
            "windows": "8cb1ef9bfe3e80e12db7db7f176e3e9280c5ae3bbb54c8dcfbb4f298c3d8fc71",
        },
    }

def _elm_compiler_impl(ctx):
    os = ctx.attr.os
    version = ctx.attr.version
    file_name = "elm"
    if os == "windows":
        file_name += ".exe"
    ctx.download(
        url = "https://github.com/elm/compiler/releases/download/{}/binary-for-{}-64-bit.gz".format(version, os),
        sha256 = ctx.attr.checksum,
        output = file_name + ".gz",
    )

    test_version = ctx.attr.test_version
    if not ELM_TEST_BINDIST.get(test_version):
        fail("Binary distribution of elm-test-rs {} is not available.".format(test_version))

    elm_test_name = "elm-test-rs"
    test_checksum = ELM_TEST_BINDIST.get(test_version).get(os)
    test_file_name = "elm-test-{}".format(os)
    test_suffix = os
    if os == "mac":
        test_suffix = "macos"
    test_extention = "tar.gz"
    if os == "windows":
        test_extention = "zip"
        elm_test_name = "elm-test-rs.exe"
    ctx.download_and_extract(
        url = "https://github.com/mpizenberg/elm-test-rs/releases/download/v{}/elm-test-rs_{}.{}".format(test_version, test_suffix, test_extention),
        sha256 = test_checksum,
    )

    ctx.file(
        "BUILD",
        executable = False,
        content = """
load("@rules_elm//elm:toolchain.bzl", "elm_toolchain", "extract_gzip")
exports_files(["{elm}.gz", "{elm_test}"])
extract_gzip(name = "{elm}", archive = "{elm}.gz")
elm_toolchain(name = "{os}_info", elm = ":{elm}", elm_test = ":{elm_test}")
        """.format(os = os, elm = file_name, elm_test = elm_test_name),
    )


_elm_compiler = repository_rule(
    _elm_compiler_impl,
    local = False,
    attrs = {
        "os": attr.string(),
        "version": attr.string(),
        "test_version": attr.string(),
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
)
        """.format(
            os = ctx.attr.os,
            bindist_name = ctx.attr.bindist_name,
            exec_constraints = exec_constraints,
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

def toolchains(version = DEFAULT_VERSION, test_version = ""):
    if not ELM_COMPILER_BINDIST.get(version):
        fail("Binary distribution of Elm {} is not available.".format(version))

    if test_version == "":
        test_version = DEFAULT_TEST_VERSION.get(version)

    for os, checksum in ELM_COMPILER_BINDIST.get(version).items():
        bindist_name = "rules_elm_compiler_{}".format(os)
        toolchain_name = bindist_name + "-toolchain"
        _elm_compiler(name = bindist_name, os = os, version = version, checksum = checksum, test_version = test_version)
        _elm_compiler_toolchain(name = toolchain_name, bindist_name = bindist_name, os = os)
        native.register_toolchains("@{}//:toolchain".format(toolchain_name))

def _elm_toolchain_impl(ctx):
    return [platform_common.ToolchainInfo(
        elm = ctx.file.elm,
        elm_test = ctx.file.elm_test,
    )]

elm_toolchain = rule(
    _elm_toolchain_impl,
    attrs = {
        "elm": attr.label(
            allow_single_file = True,
            mandatory = True,
            cfg = "exec",
        ),
        "elm_test": attr.label(
            allow_single_file = True,
            mandatory = True,
        ),
    },
)

def _extract_gzip_imp(ctx):
    archive = ctx.file.archive
    elm_compiler = ctx.actions.declare_file(ctx.label.name, sibling = archive)

    ctx.actions.run_shell(
        inputs = [ctx.file.archive],
        outputs = [elm_compiler],
        command ="""
        gunzip "{archive}" -c > "{output}"
        chmod +x "{output}"
        """.format(
            archive = ctx.file.archive.path,
            output = elm_compiler.path,
        ),
    )

    return [DefaultInfo(executable = elm_compiler)]

extract_gzip = rule(
    implementation = _extract_gzip_imp,
    attrs = {
        "archive": attr.label(
            mandatory = True,
            allow_single_file = True,
        ),
    },
    provides = [DefaultInfo],
)
