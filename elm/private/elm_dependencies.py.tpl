#!/usr/bin/env python3

# elm_dependencies.py ELM_PROJECT_ROOT
#  This program is that to install all dependencies for elm with ELM_PROJECT_ROOT/elm.json
#  expected set ELM_HOME env

import json
import os
import os.path
import shutil
import subprocess
import sys

debug = False

def run(cmd, *args, **kwargs):
    if debug:
        print("+ " + " ".join(["'{}'".format(arg) for arg in cmd]), file=sys.stderr)
        sys.stderr.flush()
    try:
        subprocess.run(cmd, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, *args, **kwargs)
    except subprocess.CalledProcessError as err:
        sys.stdout.buffer.write(err.stdout)
        sys.stderr.buffer.write(err.stderr)
        raise

elm_runtime_path = os.path.abspath("@@ELM_RUNTIME@@")
elm_project_root = sys.argv.pop(1)
bazel_home = os.getcwd()
elm_home = os.getenv("ELM_HOME")
os.environ["ELM_HOME"] = bazel_home + "/" + elm_home

os.chdir(elm_project_root)

elm_json = json.load(open("elm.json"))
if elm_json["type"] == "application":
    for srcdir in elm_json["source-directories"]:
        os.makedirs(srcdir, exist_ok = True)

with open("Main.elm", mode = "w") as f:
    f.write("import Browser\nimport Debug\nmain = Browser.sandbox (Debug.todo \"temp\")")

if debug:
    print("+ cd " + elm_project_root, file=sys.stderr)
    sys.stderr.flush()

run([elm_runtime_path, "make", "Main.elm"])

os.chdir(bazel_home)
shutil.make_archive(elm_home, "zip", root_dir = elm_home)
