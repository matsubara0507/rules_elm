def _display_elm_version(ctx):
    elm_compiler = ctx.toolchains["@rules_elm//elm:toolchain"].elm
    out_file = ctx.actions.declare_file("%s.version" % ctx.attr.name)
    ctx.actions.run_shell(
        inputs = [elm_compiler],
        outputs = [out_file],
        progress_message = "Getting version of elm",
        command = "%s --version > '%s'" % (elm_compiler.path, out_file.path)
    )
    return [DefaultInfo(files = depset([out_file]))]

display_elm_version = rule(
    _display_elm_version,
    # executable = True,
    toolchains = [
        "@rules_elm//elm:toolchain",
    ]
)
