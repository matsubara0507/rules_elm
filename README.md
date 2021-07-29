# Bazel Rules for Elm

This repository is bazel rules to build [Elm](https://elm-lang.org/) project.

## Rules

- elm_make : run `elm make`
- elm_dependencies : cache dependencies for elm_make rule

## Example

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
    elm_home = ":deps",
)
```

## Support version

- 0.19.1
- 0.19.0
