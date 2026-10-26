# Bazel Rules for Elm

[![Example](https://github.com/matsubara0507/rules_elm/actions/workflows/examples.yaml/badge.svg)](https://github.com/matsubara0507/rules_elm/actions/workflows/examples.yaml)

This repository is bazel rules to build [Elm](https://elm-lang.org/) project.

## Rules

- elm_make : run `elm make`
- elm_dependencies : cache dependencies for elm_make rule
- elm_test : run [`elm-test-rs`](https://github.com/mpizenberg/elm-test-rs)

Tested with Bazel 7, 8 and 9. `WORKSPACE` is tested only with Bazel 7, since it is disabled by default in Bazel 8 and removed in Bazel 9.

## Usage

`WORKSPACE`

```py
git_repository(
    name = "rules_elm",
    remote = "https://github.com/matsubara0507/rules_elm",
    commit = "xxx",
    shallow_since = "yyy",
)

load("@rules_elm//elm:repositories.bzl", rules_elm_repositories = "repositories")

rules_elm_repositories()

load("@rules_elm//elm:toolchain.bzl", rules_elm_toolchains = "toolchains")

rules_elm_toolchains(version = "0.19.1")

# for elm-test
load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

# rules_nodejs requires bazel_lib
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
```

`MODULE.bazel`

```py
bazel_dep(name = "rules_elm", version = "x.y.z")

elm = use_extension("@rules_elm//elm:extensions.bzl", "toolchains")
elm.toolchains(
    version = "0.19.1",
    test_version = "3.0",
)

use_repo(
    elm,
    "rules_elm_compiler_linux",
    "rules_elm_compiler_mac",
    "rules_elm_compiler_mac-arm",
    "rules_elm_compiler_windows",
    "rules_elm_compiler_linux-toolchain",
    "rules_elm_compiler_mac-toolchain",
    "rules_elm_compiler_mac-arm-toolchain",
    "rules_elm_compiler_windows-toolchain",
)

register_toolchains(
    "@rules_elm_compiler_linux-toolchain//:toolchain",
    "@rules_elm_compiler_mac-toolchain//:toolchain",
    "@rules_elm_compiler_mac-arm-toolchain//:toolchain",
    "@rules_elm_compiler_windows-toolchain//:toolchain",
)
```

If you use `elm_test`, you also need to register Node.js toolchains (and Python toolchains if your workspace requires it).

### Example

Please see [examples/build-project](/examples/build-project)

```py
load("@rules_elm//elm:def.bzl", "elm_make", "elm_dependencies")

elm_dependencies(
    name = "deps",
    elm_json = "elm.json",
)

elm_make(
    name = "index",
    srcs = glob(["**"]),
    elm_json = "elm.json",
    main = "src/Main.elm",
    output = "index.html",
    optimize = True,
    elm_home = ":deps",
)

elm_test(
    name = "sample-test",
    tests = glob(["test/**"]),
    srcs = glob(["src/**"]),
    elm_json = "elm.json",
    elm_home = ":deps",
)
```

## Support version

- 0.19.3
- 0.19.2
- 0.19.1
- 0.19.0

### elm-test-rs

- 1.2.1
- 2.0.2
- 3.0
- 3.2.0

If `test_version` is not specified, elm-test-rs 3.2.0 is used for Elm 0.19.2 and later, and 3.0 is used for Elm 0.19.1.
