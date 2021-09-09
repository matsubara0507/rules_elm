load("@rules_python//python:defs.bzl", "py_binary")

def _elm_test_wrapper_impl(ctx):
    elm_compiler = ctx.toolchains["@rules_elm//elm:toolchain"].elm
    elm_test_bin = ctx.toolchains["@rules_elm//elm:toolchain"].elm_test

    substitutions = {
        "@@ELM_RUNTIME@@": elm_compiler.path,
        "@@ELM_TEST@@": elm_test_bin.path,
        "@@PROJECT_ROOT@@": ctx.file.elm_json.short_path.rsplit("/", 1)[0],
        "@@ELM_HOME_ZIP@@": "",
        "@@VERBOSE@@": "",
    }

    if ctx.attr.vvv:
        substitutions["@@VERBOSE@@"] = "true"

    if ctx.file.elm_home != None:
        substitutions["@@ELM_HOME_ZIP@@"] = ctx.file.elm_home.short_path

    elm_wrapper = ctx.actions.declare_file(ctx.attr.src_name + ".py")
    ctx.actions.expand_template(
        template = ctx.file.elm_wrapper_tpl,
        output = elm_wrapper,
        is_executable = True,
        substitutions = substitutions,
    )
    return [DefaultInfo(files = depset([elm_wrapper]))]

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
    ]
)

def _elm_test_impl(ctx):
    # Because returned executables must be created from the same rule, the
    # launcher target is simply symlinked and exposed.
    launcher_name = ctx.label.name + "-launcher"
    if ctx.attr.is_windows:
        launcher_name += ".exe"

    launcher = ctx.actions.declare_file(launcher_name)
    ctx.actions.symlink(
        output = launcher,
        target_file = ctx.executable.launcher,
        is_executable = True,
    )

    inputs = [
        ctx.toolchains["@rules_elm//elm:toolchain"].elm,
        ctx.toolchains["@rules_elm//elm:toolchain"].elm_test,
        ctx.file.elm_json,
        ctx.file.elm_home,
    ] + ctx.files.srcs + ctx.files.tests
    return [DefaultInfo(
        executable = launcher,
        runfiles = ctx.runfiles(files = inputs).merge(ctx.attr.launcher.data_runfiles),
    )]

_elm_test = rule(
    _elm_test_impl,
    test = True,
    attrs = {
        "tests": attr.label_list(allow_files = True),
        "srcs": attr.label_list(allow_files = True),
        "elm_json": attr.label(
            mandatory = True,
            allow_single_file = True,
        ),
        "elm_home": attr.label(
            allow_single_file = True,
        ),
        "launcher": attr.label(
            executable = True,
            cfg = "host",
        ),
        "is_windows": attr.bool(),
    },
    toolchains = [
        "@rules_elm//elm:toolchain",
    ],
)

def elm_test(name, **kwargs):
    _elm_test_wrapper(
        name = name + "-launcher.py",
        src_name = name + "-launcher",
        elm_wrapper_tpl = Label("@rules_elm//elm/private:elm_test_wrapper.py.tpl"),
        **kwargs,
    )
    py_binary(
        name = name + "-launcher",
        srcs = [name + "-launcher.py"],
        srcs_version = "PY3",
        python_version = "PY3",
        deps = [
            "@bazel_tools//tools/python/runfiles",
        ],
    )
    _elm_test(
        name = name,
        launcher = name + "-launcher",
        is_windows = select({
            "@bazel_tools//src/conditions:host_windows": True,
            "//conditions:default": False,
        }),
        **kwargs,
    )
