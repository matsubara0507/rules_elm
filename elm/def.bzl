def _elm_make_impl(ctx):
    elm_compiler = ctx.toolchains["@rules_elm//elm:toolchain"].elm
    output_file = ctx.actions.declare_file(ctx.attr.output)

    ctx.actions.run(
        executable = ctx.executable._elm_wrapper,
        arguments = [
            ctx.file.elm_json.dirname,
            "make", ctx.attr.main, "--output", output_file.path,
        ],
        inputs = [elm_compiler, ctx.file.elm_json] + ctx.files.srcs,
        outputs = [output_file],
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
