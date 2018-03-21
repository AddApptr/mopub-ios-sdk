#!/bin/sh

set -e
set -o pipefail

function showHelp() {
  echo "Usage: bash $0 [OPTIONS] <release_type>"
  echo ""
  echo "Options:"
  echo "  -x XCODE_PATH Use the Xcode Installation from XCODE_PATH instead of the current one."
  echo ""
}

function build_mopub_sdk_simulator() {
  xcodebuild -project MoPubSDK.xcodeproj -configuration Release -sdk iphonesimulator -target MoPubSDK clean install
}

function build_mopub_sdk_device() {
  xcodebuild -project MoPubSDK.xcodeproj -configuration Release -sdk iphoneos -target MoPubSDK clean install
}



while getopts "x:h" opt; do
  case "$opt" in
  h)
    showHelp
    exit
    ;;
  x)
    echo "$0: Will use Xcode from ${OPTARG}"
    export DEVELOPER_DIR="${OPTARG}/Contents/Developer"
    ;;
  \?)
    showHelp >&2
    exit 1
    ;;
  *)
    echo "unexpected option: $opt" # FIXME: Add script name and line number.
    exit 1
    ;;
  esac
done


if test -f build/Release*/libMoPubSDK.a
then
  echo "MoPub SDK is already present in build/Release -> removing"
  rm -f build/Release*/libMoPubSDK.a
fi


if test -f libMoPubSDK.a
then
  echo "MoPub SDK is already present -> removing"
  rm -f libMoPubSDK.a
fi

build_mopub_sdk_simulator
build_mopub_sdk_device

lipo -create build/Release*/libMoPubSDK.a -output libMoPubSDK.a

lipo -info libMoPubSDK.a

