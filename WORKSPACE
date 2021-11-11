workspace(name = "rules_elm")

load("@rules_elm//elm:repositories.bzl", rules_elm_repositories = "repositories")

rules_elm_repositories()

load("@rules_elm//elm:toolchain.bzl", rules_elm_toolchains = "toolchains")

rules_elm_toolchains(version = "0.19.1")

# for elm-test
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

http_archive(
    name = "rules_nodejs",
    sha256 = "995eb2fbcd6c0d27faea1f8b362a3a448d98d42b6c0fddc2943b72fe866a9d8e",
    urls = ["https://github.com/bazelbuild/rules_nodejs/releases/download/4.4.4/rules_nodejs-core-4.4.4.tar.gz"],
)

load("@rules_nodejs//nodejs:repositories.bzl", "rules_nodejs_dependencies", "nodejs_register_toolchains")

rules_nodejs_dependencies()

nodejs_register_toolchains(
    name = "node16",
    node_version = "16.13.0",
)
