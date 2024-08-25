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

# for elm-test
http_archive(
    name = "rules_nodejs",
    sha256 = "5ad078287b5f3069735652e1fc933cb2e2189b15d2c9fc826c889dc466c32a07",
    strip_prefix = "rules_nodejs-6.0.1",
    url = "https://github.com/bazelbuild/rules_nodejs/releases/download/v6.0.1/rules_nodejs-v6.0.1.tar.gz",
)

load("@rules_nodejs//nodejs:repositories.bzl", "rules_nodejs_dependencies", "nodejs_register_toolchains")

rules_nodejs_dependencies()

nodejs_register_toolchains(
    name = "node18",
    node_version = "18.17.1",
)
