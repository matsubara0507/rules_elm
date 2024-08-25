# Bazel Rules for Elm

[![Example](https://github.com/matsubara0507/rules_elm/actions/workflows/examples.yaml/badge.svg)](https://github.com/matsubara0507/rules_elm/actions/workflows/examples.yaml)

This repository is bazel rules to build [Elm](https://elm-lang.org/) project.

## Rules

- elm_make : run `elm make`
- elm_dependencies : cache dependencies for elm_make rule
- elm_test : run [`elm-test-rs`](https://github.com/mpizenberg/elm-test-rs)

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
```

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

- 0.19.1
- 0.19.0

### elm-test-rs

- 1.2.1
- 2.0.2
- 3.0
