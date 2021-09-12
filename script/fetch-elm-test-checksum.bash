#!/bin/bash

VERSION=$1

for OS in "linux.tar.gz" "macos.tar.gz" "windows.zip"
do
  wget --quiet "https://github.com/mpizenberg/elm-test-rs/releases/download/${VERSION}/elm-test-rs_${OS}"
  shasum -a 256 "elm-test-rs_${OS}"
  rm "elm-test-rs_${OS}"
done
