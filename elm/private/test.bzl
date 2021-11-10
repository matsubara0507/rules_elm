load("@rules_python//python:defs.bzl", "py_test")

def _elm_test_wrapper_impl(ctx):
    elm_compiler = ctx.toolchains["@rules_elm//elm:toolchain"].elm
    elm_test_bin = ctx.toolchains["@rules_elm//elm:toolchain"].elm_test
    nodeinfo = ctx.toolchains["@rules_nodejs//nodejs:toolchain_type"].nodeinfo

    inputs = [
        elm_compiler,
        elm_test_bin,
        ctx.file.elm_json,
    ] + ctx.files.srcs + ctx.files.tests + nodeinfo.tool_files


    test_filepaths = []
    for file in ctx.files.tests:
        test_filepaths.append(file.short_path)

    substitutions = {
        "@@ELM_RUNTIME@@": elm_compiler.short_path,
        "@@ELM_TEST@@": elm_test_bin.short_path,
        "@@PROJECT_ROOT@@": "./{}".format(ctx.file.elm_json.short_path).rsplit("/", 1)[0],
        "@@TEST_FILES@@": " ".join(test_filepaths),
        "@@ELM_HOME_ZIP@@": "",
        "@@VERBOSE@@": "",
    }

    if ctx.attr.vvv:
        substitutions["@@VERBOSE@@"] = "true"

    if ctx.file.elm_home != None:
        substitutions["@@ELM_HOME_ZIP@@"] = ctx.file.elm_home.short_path
        inputs.append(ctx.file.elm_home)

    elm_wrapper = ctx.actions.declare_file(ctx.attr.src_name + ".py")
    ctx.actions.expand_template(
        template = ctx.file.elm_wrapper_tpl,
        output = elm_wrapper,
        is_executable = True,
        substitutions = substitutions,
    )
    return [DefaultInfo(files = depset([elm_wrapper]), runfiles = ctx.runfiles(files = inputs))]

_elm_test_wrapper = rule(
    _elm_test_wrapper_impl,
    attrs = {
        "src_name": attr.string(),
        "elm_wrapper_tpl": attr.label(
            allow_single_file = True,
        ),
        "tests": attr.label_list(allow_files = True),
        "srcs": attr.label_list(allow_files = True),
        "elm_json": attr.label(
            mandatory = True,
            allow_single_file = True,
        ),
        "elm_home": attr.label(
            allow_single_file = True,
        ),
        "vvv": attr.bool(),
     },
    toolchains = [
        "@rules_elm//elm:toolchain",
        "@rules_nodejs//nodejs:toolchain_type",
    ]
)

def elm_test(name, **kwargs):
    _elm_test_wrapper(
        name = name + ".py",
        src_name = name,
        elm_wrapper_tpl = Label("@rules_elm//elm/private:elm_test_wrapper.py.tpl"),
        **kwargs,
    )
    py_test(
        name = name,
        srcs = [name + ".py"],
        srcs_version = "PY3",
        python_version = "PY3",
    )
