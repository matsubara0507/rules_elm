#!/bin/bash

VERSION=$1

for OS in "linux.tar.gz" "macos.tar.gz" "macos-arm.tar.gz" "windows.zip"
do
  wget --quiet "https://github.com/mpizenberg/elm-test-rs/releases/download/v${VERSION}/elm-test-rs_${OS}"
  shasum -a 256 "elm-test-rs_${OS}"
  rm "elm-test-rs_${OS}"
done
