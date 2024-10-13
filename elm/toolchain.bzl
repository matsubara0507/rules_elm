load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive", "http_file")
load("@bazel_skylib//lib:versions.bzl", "versions")

DEFAULT_ELM_REPOSITORY = "elm"

ELM_PLATFORMS = \
    {
        "linux_amd64": struct(
            elm_binary_name = "binary-for-linux-64-bit.gz",
            elm_test_binary_name = "elm-test-rs_linux.tar.gz",
            compatible_with = ["@platforms//os:linux", "@platforms//cpu:x86_64"],
        ),
        "darwin_amd64": struct(
            elm_binary_name = "binary-for-mac-64-bit.gz",
            elm_test_binary_name = "elm-test-rs_macos.tar.gz",
            compatible_with = ["@platforms//os:osx", "@platforms//cpu:x86_64"],
        ),
        "darwin_arm64": struct(
            elm_binary_name = "binary-for-mac-64-bit-ARM.gz",
            elm_test_binary_name = "elm-test-rs_macos-arm.tar.gz",
            compatible_with = ["@platforms//os:osx", "@platforms//cpu:arm64"],
        ),
        "windows_amd64": struct(
            elm_binary_name = "binary-for-windows-64-bit.gz",
            elm_test_binary_name = "elm-test-rs_windows.zip",
            compatible_with = ["@platforms//os:windows", "@platforms//cpu:x86_64"],
        ),
    }

DEFAULT_VERSION = "0.19.1"

ELM_COMPILER_BINDIST = \
    {
        "0.19.1": {
            "linux_amd64": "e44af52bb27f725a973478e589d990a6428e115fe1bb14f03833134d6c0f155c",
            "darwin_amd64": "05289f0e3d4f30033487c05e689964c3bb17c0c48012510dbef1df43868545d1",
            "darwin_arm64": "552c8300b55dafdf52073b095e7bc6afc1b2ea2a600fbc7654bca8a241e38689",
            "windows_amd64": "d1bf666298cbe3c5447b9ca0ea608552d750e5d232f9845c2af11907b654903b",
        },
        "0.19.0": {
            "linux_amd64": "d359adbee89823c641cda326938708d7227dc79aa1f162e0d8fe275f182f528a",
            "darwin_amd64": "f1fa4dd9021e94c5a58b2be8843e3329095232ee3bd21a23524721a40eaabd35",
            "windows_amd64": "0e27d80537418896cf98326224159a45b6d36bf08e608e3a174ab6d2c572c5ae",
        },
    }

DEFAULT_TEST_VERSION = "3.0"

ELM_TEST_BINDIST = \
    {
        "1.2.1": {
            "linux_amd64": "6e5759f832a5e025898c9306ba47b2f9ed7f0c371dc69bd16c15c7ed8bfb1501",
            "darwin_amd64": "890c45a7eda24fd13169d349af9c835ee3ed04974eec36953baba5aefc3628a8",
            "darwin_arm64": "605dbe1976cd345a9a5cc3c77620cc268fef2a8ef701c5ac49157c4ac2c592eb",
            "windows_amd64": "26add13880af484a47cd182547f41370d3bfca812a7cc9e3db6f41ce13b7fc40",
        },
        "2.0.2": {
            "linux_amd64": "ede814df1dec5781e00dccba56ad38d901af2c8be55a33bd31e0fbcf2b5ee771",
            "darwin_amd64": "d24d73edea77d607c488d8aecf083e09b6e3873d71b109269ab38b35dfd60236",
            "darwin_arm64": "9a8bd4d10324036a33ce8c7bbd7f61a73b9054451ff9c2347632ba084b456ef9",
            "windows_amd64": "5baa282339b8e36e7a0b2ff87733fd2f01dd8b31dedaa12332ad24f706a91ba4",
        },
        "3.0": {
            "linux_amd64": "c72702d32a2a9e051667febeeef486a1794798d0770be1a9da95895e10b6db0f",
            "darwin_amd64": "41e2be1d77fb587ac1336f4b8822feb3b914eff7364715f6cac0bc4a90c0948a",
            "darwin_arm64": "8701bf104b315446d64ae4d1689aa6a3bad1a85e1b31a9c9907ac911837b5fd1",
            "windows_amd64": "8cb1ef9bfe3e80e12db7db7f176e3e9280c5ae3bbb54c8dcfbb4f298c3d8fc71",
        },
    }

def _elm_compiler_impl(ctx):
    platform = ctx.attr.platform
    meta = ELM_PLATFORMS.get(platform)

    version = ctx.attr.version
    elm_checksum = ELM_COMPILER_BINDIST.get(version).get(platform)
    file_name = "elm"
    if platform == "windows_amd64":
        file_name += ".exe"
    ctx.download(
        url = "https://github.com/elm/compiler/releases/download/{}/{}".format(version, meta.elm_binary_name),
        sha256 = elm_checksum,
        output = file_name + ".gz",
    )

    test_version = ctx.attr.test_version
    elm_test_name = "elm-test-rs"
    if platform == "windows_amd64":
        elm_test_name = "elm-test-rs.exe"
    test_checksum = ELM_TEST_BINDIST.get(test_version).get(platform)
    if platform == "darwin_arm64" and not versions.is_at_least("7.2.0", versions.get()):
        # https://github.com/bazelbuild/bazel/issues/20269
        ctx.download(
            url = "https://github.com/mpizenberg/elm-test-rs/releases/download/v{}/{}".format(test_version, meta.elm_test_binary_name),
            sha256 = test_checksum,
            output = elm_test_name + ".tar.gz",
        )
        ctx.file(
            "BUILD",
            executable = False,
            content = """
load("@rules_elm//elm:toolchain.bzl", "elm_toolchain", "extract_gzip", "extract_targz")
exports_files(["{elm}.gz", "{elm_test}.tar.gz"])
extract_gzip(name = "{elm}", archive = "{elm}.gz")
extract_targz(name = "{elm_test}", archive = "{elm_test}.tar.gz")
elm_toolchain(name = "toolchain", elm = ":{elm}", elm_test = ":{elm_test}")
            """.format(elm = file_name, elm_test = elm_test_name),
        )
    else:
        ctx.download_and_extract(
            url = "https://github.com/mpizenberg/elm-test-rs/releases/download/v{}/{}".format(test_version, meta.elm_test_binary_name),
            sha256 = test_checksum,
        )
        ctx.file(
            "BUILD",
            executable = False,
            content = """
load("@rules_elm//elm:toolchain.bzl", "elm_toolchain", "extract_gzip")
exports_files(["{elm}.gz", "{elm_test}"])
extract_gzip(name = "{elm}", archive = "{elm}.gz")
elm_toolchain(name = "toolchain", elm = ":{elm}", elm_test = ":{elm_test}")
            """.format(elm = file_name, elm_test = elm_test_name),
        )


_elm_compiler = repository_rule(
    _elm_compiler_impl,
    local = False,
    attrs = {
        "platform": attr.string(),
        "version": attr.string(),
        "test_version": attr.string(),
    },
)

def _elm_toolchains_repo_impl(ctx):
    build_content = ""
    for platform, _ in ELM_COMPILER_BINDIST.get(ctx.attr.version).items():
        meta = ELM_PLATFORMS.get(platform)
        build_content += """
toolchain(
    name = "{platform}_toolchain",
    toolchain = "@{repo_name}_{platform}//:toolchain",
    toolchain_type = "@rules_elm//elm:toolchain",
    exec_compatible_with = {compatible_with},
)
        """.format(
            platform = platform,
            repo_name = ctx.attr.repo_name,
            compatible_with = meta.compatible_with,
        )


    ctx.file("BUILD.bazel", build_content)


elm_toolchains_repo = repository_rule(
    _elm_toolchains_repo_impl,
    attrs = {
        "repo_name": attr.string(),
        "version": attr.string(),
    }
)

def toolchains(name = DEFAULT_ELM_REPOSITORY, version = DEFAULT_VERSION, test_version = DEFAULT_TEST_VERSION, register = True):
    if not ELM_COMPILER_BINDIST.get(version):
        fail("Binary distribution of Elm {} is not available.".format(version))

    if not ELM_TEST_BINDIST.get(test_version):
        fail("Binary distribution of elm-test-rs {} is not available. ".format(test_version))

    for platform, checksum in ELM_COMPILER_BINDIST.get(version).items():
        _elm_compiler(
            name = name + "_" + platform,
            platform = platform,
            version = version,
            test_version = test_version,
        )
        if register:
            native.register_toolchains("@{}_toolchains//:{}_toolchain".format(name, platform))

    elm_toolchains_repo(name = name + "_toolchains", repo_name = name, version = version)

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
    output = ctx.actions.declare_file(ctx.label.name, sibling = archive)

    ctx.actions.run_shell(
        inputs = [ctx.file.archive],
        outputs = [output],
        command ="""
        gunzip "{archive}" -c > "{output}"
        chmod +x "{output}"
        """.format(
            archive = ctx.file.archive.path,
            output = output.path,
        ),
    )

    return [DefaultInfo(executable = output)]

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

def _extract_targz_imp(ctx):
    archive = ctx.file.archive
    output = ctx.actions.declare_file(ctx.label.name, sibling = archive)

    ctx.actions.run_shell(
        inputs = [ctx.file.archive],
        outputs = [output],
        command ="""
        tar -zxf "{archive}" -C "{output_dir}"
        chmod +x "{output}"
        """.format(
            archive = ctx.file.archive.path,
            output_dir = output.dirname,
            output = output.path,
        ),
    )

    return [DefaultInfo(executable = output)]

extract_targz = rule(
    implementation = _extract_targz_imp,
    attrs = {
        "archive": attr.label(
            mandatory = True,
            allow_single_file = True,
        ),
    },
    provides = [DefaultInfo],
)
