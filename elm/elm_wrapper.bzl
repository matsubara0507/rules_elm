load("@rules_python//python:defs.bzl", "py_binary")

def _elm_wrapper_impl(ctx):
    elm_compiler = ctx.toolchains["@rules_elm//elm:toolchain"].elm

    elm_wrapper = ctx.actions.declare_file("elm_wrapper.py")
    ctx.actions.expand_template(
        template = ctx.file._elm_wrapper_tpl,
        output = elm_wrapper,
        is_executable = True,
        substitutions = {
            "@@ELM_RUNTIME@@": elm_compiler.path,
        }
    )
    return [DefaultInfo(files = depset([elm_wrapper]))]

_elm_wrapper = rule(
    _elm_wrapper_impl,
    attrs = {
        "_elm_wrapper_tpl": attr.label(
            allow_single_file = True,
            default = Label("@rules_elm//elm:private/elm_wrapper.py.tpl"),
        ),
    },
    toolchains = [
        "@rules_elm//elm:toolchain",
    ]
)

def elm_wrapper(name, **kwargs):
    _elm_wrapper(name = name + ".py")
    py_binary(
        name = name,
        srcs = [name + ".py"],
        srcs_version = "PY3",
        python_version = "PY3",
        deps = [
            "@bazel_tools//tools/python/runfiles",
        ],
        **kwargs
    )
