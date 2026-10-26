#!/bin/bash

VERSION=$1

# Since 0.19.2, binaries are published as elm-${VERSION}-${PLATFORM}.gz.
if [ "$(printf '%s\n' "0.19.2" "${VERSION}" | sort -V | head -n1)" = "0.19.2" ]; then
  for PLATFORM in "linux-x64" "mac-x64" "mac-arm" "windows-x64"
  do
    wget --quiet "https://github.com/elm/compiler/releases/download/${VERSION}/elm-${VERSION}-${PLATFORM}.gz"
    shasum -a 256 "elm-${VERSION}-${PLATFORM}.gz"
    rm "elm-${VERSION}-${PLATFORM}.gz"
  done
  exit 0
fi

for OS in "linux" "mac" "windows"
do
  wget --quiet "https://github.com/elm/compiler/releases/download/${VERSION}/binary-for-${OS}-64-bit.gz"
  shasum -a 256 "binary-for-${OS}-64-bit.gz"
  rm "binary-for-${OS}-64-bit.gz"
done

wget --quiet "https://github.com/elm/compiler/releases/download/${VERSION}/binary-for-mac-64-bit-ARM.gz"
shasum -a 256 "binary-for-mac-64-bit-ARM.gz"
rm "binary-for-mac-64-bit-ARM.gz"
