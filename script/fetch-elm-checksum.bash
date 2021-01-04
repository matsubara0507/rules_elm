#!/bin/bash

VERSION=$1

for OS in "linux" "mac" "windows"
do
  wget --quiet "https://github.com/elm/compiler/releases/download/${VERSION}/binary-for-${OS}-64-bit.gz"
  shasum -a 256 "binary-for-${OS}-64-bit.gz"
  rm "binary-for-${OS}-64-bit.gz"
done
