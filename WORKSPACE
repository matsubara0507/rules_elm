workspace(name = "rules_elm")

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "bazel_skylib",
    sha256 = "66ffd9315665bfaafc96b52278f57c7e2dd09f5ede279ea6d39b2be471e7e3aa",
    urls = [
        "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/1.4.2/bazel-skylib-1.4.2.tar.gz",
        "https://github.com/bazelbuild/bazel-skylib/releases/download/1.4.2/bazel-skylib-1.4.2.tar.gz",
    ],
)

load("@bazel_skylib//:workspace.bzl", "bazel_skylib_workspace")

bazel_skylib_workspace()

load("@rules_elm//elm:repositories.bzl", rules_elm_repositories = "repositories")

rules_elm_repositories()

load("@rules_elm//elm:toolchain.bzl", rules_elm_toolchains = "toolchains")

rules_elm_toolchains(version = "0.19.1")

# for elm-test (rules_nodejs requires bazel_lib)
http_archive(
    name = "bazel_lib",
    sha256 = "6fd3b1e1a38ca744f9664be4627ced80895c7d2ee353891c172f1ab61309c933",
    strip_prefix = "bazel-lib-3.0.0",
    url = "https://github.com/bazel-contrib/bazel-lib/releases/download/v3.0.0/bazel-lib-v3.0.0.tar.gz",
)

load("@bazel_lib//lib:repositories.bzl", "bazel_lib_dependencies", "bazel_lib_register_toolchains")

bazel_lib_dependencies()

load("@rules_shell//shell:repositories.bzl", "rules_shell_dependencies", "rules_shell_toolchains")

rules_shell_dependencies()

rules_shell_toolchains()

bazel_lib_register_toolchains()

load("@bazel_tools//tools/build_defs/repo:utils.bzl", "maybe")
load("@platforms//host:extension.bzl", "host_platform_repo")

maybe(
    host_platform_repo,
    name = "host_platform",
)

http_archive(
    name = "rules_nodejs",
    sha256 = "f87453e0d6a97b4d2e6d22070a447b6d304727bf61ff8e31ce25ded0319005dd",
    strip_prefix = "rules_nodejs-6.7.7",
    url = "https://github.com/bazel-contrib/rules_nodejs/releases/download/v6.7.7/rules_nodejs-v6.7.7.tar.gz",
)

load("@rules_nodejs//nodejs:repositories.bzl", "rules_nodejs_dependencies", "nodejs_register_toolchains")

rules_nodejs_dependencies()

nodejs_register_toolchains(
    name = "node24",
    node_version = "24.22.1",
)
