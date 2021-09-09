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
        subprocess.run(cmd, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, *args, **kwargs)
    except subprocess.CalledProcessError as err:
        sys.stdout.buffer.write(err.stdout)
        sys.stderr.buffer.write(err.stderr)
        raise

elm_runtime_path = os.path.abspath("@@ELM_RUNTIME@@")
elm_test_path = os.path.abspath("@@ELM_TEST@@")

if os.getenv("ELM_HOME_ZIP") == None:
    # To don't occur error from elm compiler:
    #   HOME: getAppUserDataDirectory:getEnv: does not exist (no environment variable)
    os.putenv("HOME", os.getcwd())
else:
    elm_home = os.getcwd() + "/.elm"
    elm_home_zip = os.getenv("ELM_HOME_ZIP")
    with zipfile.ZipFile(elm_home_zip) as elm_zip:
        elm_zip.extractall(elm_home)
    os.environ["ELM_HOME"] = elm_home

run([elm_test_path, "--compiler", elm_runtime_path] + sys.argv[1:])