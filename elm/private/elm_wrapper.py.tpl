#!/usr/bin/env python3

# elm_wrapper.py ELM_PROJECT_ROOT [ARGS_FOR_ELM...]
#   Exec elm command with ARGS_FOR_ELM before `cd ELM_PROJECT_ROOT`
#   NOTE: If have `--output PATH` arguments, change PATH to absolute path

import os
import os.path
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

for i, arg in enumerate(sys.argv):
    if arg == "--output":
        sys.argv[i+1] = os.path.abspath(sys.argv[i+1])

# To don't occur error from elm compiler:
#   HOME: getAppUserDataDirectory:getEnv: does not exist (no environment variable)
os.putenv("HOME", os.getcwd())

os.chdir(elm_project_root)
if debug:
    print("+ cd " + elm_project_root, file=sys.stderr)
    sys.stderr.flush()

run([elm_runtime_path] + sys.argv[1:])
