load("//elm/private:test.bzl", _elm_test = "elm_test")

elm_test = _elm_test

def _elm_make_impl(ctx):
    elm_compiler = ctx.toolchains["@rules_elm//elm:toolchain"].elm
    output_file = ctx.actions.declare_file(ctx.attr.output)

    env = {}
    inputs = [elm_compiler, ctx.file.elm_json] + ctx.files.srcs
    if ctx.file.elm_home != None:
        env["ELM_HOME_ZIP"] = ctx.file.elm_home.path
        inputs.append(ctx.file.elm_home)

    arguments = [
        ctx.file.elm_json.dirname,
        "make", ctx.attr.main,
        "--output", output_file.path,
    ]
    if ctx.attr.optimize:
        arguments.append("--optimize")

    ctx.actions.run(
        executable = ctx.executable._elm_wrapper,
        arguments = arguments,
        inputs = inputs,
        outputs = [output_file],
        env = env,
    )
    return [DefaultInfo(files = depset([output_file]))]

elm_make = rule(
    _elm_make_impl,
    attrs = {
        "srcs": attr.label_list(allow_files = True),
        "elm_json": attr.label(
            mandatory = True,
            allow_single_file = True,
        ),
        "main": attr.string(
            default = "src/Main.elm",
        ),
        "output": attr.string(
            default = "index.html",
        ),
        "optimize": attr.bool(),
        "elm_home": attr.label(
            allow_single_file = True,
        ),
        "_elm_wrapper": attr.label(
            executable = True,
            cfg = "host",
            default = Label("@rules_elm//elm/private:elm_wrapper"),
        ),
    },
    toolchains = [
        "@rules_elm//elm:toolchain",
    ]
)

def _elm_dependencies_impl(ctx):
    elm_compiler = ctx.toolchains["@rules_elm//elm:toolchain"].elm
    elm_home = ctx.actions.declare_directory(".elm")
    output = ctx.actions.declare_file(".elm.zip")

    ctx.actions.run(
        executable = ctx.executable._elm_wrapper,
        arguments = [ctx.file.elm_json.dirname],
        inputs = [elm_compiler, ctx.file.elm_json],
        outputs = [output, elm_home],
        env = {"ELM_HOME": elm_home.path},
    )
    return [DefaultInfo(files = depset([output]))]

elm_dependencies = rule(
    _elm_dependencies_impl,
    attrs = {
        "elm_json": attr.label(
            mandatory = True,
            allow_single_file = True,
        ),
        "_elm_wrapper": attr.label(
            executable = True,
            cfg = "host",
            default = Label("@rules_elm//elm/private:elm_dependencies"),
        ),
    },
    toolchains = [
        "@rules_elm//elm:toolchain",
    ]
)

def _elm_test_impl(ctx):
    elm_compiler = ctx.toolchains["@rules_elm//elm:toolchain"].elm
    elm_test_bin = ctx.toolchains["@rules_elm//elm:toolchain"].elm_test
    project_root = ctx.file.elm_json.short_path.rsplit("/", 1)[0]

    inputs = [elm_compiler, elm_test_bin, ctx.file.elm_json, ctx.file.elm_home] + ctx.files.srcs + ctx.files.tests

    arguments = [
        "--project", project_root,
    ]
    if ctx.attr.vvv:
        arguments.append("-vvv")

    env = ""
    if ctx.file.elm_home != None:
        env = "ELM_HOME_ZIP={} ".format(ctx.file.elm_home.short_path)

    runner_filename = ctx.attr.name + ".sh"
    runner_file = ctx.actions.declare_file(runner_filename)
    ctx.actions.write(
        output = runner_file,
        content = "#!/bin/sh\n{env}{cmd} {args}".format(
            env = env, 
            cmd = ctx.executable._elm_test_wrapper.short_path, 
            args = " ".join(arguments),
        ),
        is_executable = True,
    )

    return [DefaultInfo(
        executable = runner_file,
        runfiles = ctx.runfiles(files = inputs).merge(ctx.attr._elm_test_wrapper.data_runfiles),
    )]

