def _elm_make_impl(ctx):
    elm_compiler = ctx.toolchains["@rules_elm//elm:toolchain"].elm
    output_file = ctx.actions.declare_file(ctx.attr.output)

    env = {}
    inputs = [elm_compiler, ctx.file.elm_json] + ctx.files.srcs
    if ctx.file.elm_home != None:
        env["ELM_HOME_ZIP"] = ctx.file.elm_home.path
        inputs.append(ctx.file.elm_home)

    ctx.actions.run(
        executable = ctx.executable._elm_wrapper,
        arguments = [
            ctx.file.elm_json.dirname,
            "make", ctx.attr.main, "--output", output_file.path,
        ],
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
        "elm_home": attr.label(
            allow_single_file = True,
        ),
        "_elm_wrapper": attr.label(
            executable = True,
            cfg = "host",
            default = Label("@rules_elm//elm:elm_wrapper"),
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
            default = Label("@rules_elm//elm:elm_dependencies"),
        ),
    },
    toolchains = [
        "@rules_elm//elm:toolchain",
    ]
)
