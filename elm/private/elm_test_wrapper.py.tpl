#!/usr/bin/env python3

import os
import os.path
import subprocess
import sys
import zipfile

debug = False

def run(cmd, *args, **kwargs):
    if debug:
        print("+ " + " ".join(["'{}'".format(arg) for arg in cmd]), file=sys.stderr)
        sys.stderr.flush()
    try:
        subprocess.run(cmd, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True, *args, **kwargs)
    except subprocess.CalledProcessError as err:
        sys.stdout.buffer.write(err.stdout)
        sys.stderr.buffer.write(err.stderr)
        raise

elm_runtime_path = os.path.abspath("@@ELM_RUNTIME@@")
elm_test_path = os.path.abspath("@@ELM_TEST@@")
project_root = os.path.abspath("@@PROJECT_ROOT@@")
test_filepaths = "@@TEST_FILES@@".split(" ")

if "@@ELM_HOME_ZIP@@" == "":
    # To don't occur error from elm compiler:
    #   HOME: getAppUserDataDirectory:getEnv: does not exist (no environment variable)
    os.putenv("HOME", os.getcwd())
else:
    elm_home = os.getcwd() + "/.elm"
    elm_home_zip = os.path.abspath("@@ELM_HOME_ZIP@@")
    with zipfile.ZipFile(elm_home_zip) as elm_zip:
        elm_zip.extractall(elm_home)
    os.environ["ELM_HOME"] = elm_home

args = ["--compiler", elm_runtime_path, "--project", project_root]
if "@@VERBOSE@@" != "":
    args.append("-vvv")

run("{cmd} {args}".format(cmd = elm_test_path, args = " ".join(args + test_filepaths)))
