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

function build_mopub_resource_bundle() {
  xcodebuild -project MoPubSDK.xcodeproj -configuration Release  -target MoPubResources clean install
}



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

# Remove previoud output folder
MOPUB_OUTPUT_FOLDER='MoPub_Build_for_AATKit'
rm -rf $MOPUB_OUTPUT_FOLDER

# Build for simulator and device
build_mopub_sdk_simulator
lipo -create build/Release-iphonesimulator/libMoPubSDK.a -output libMoPubSDKSimulator.a
build_mopub_sdk_device
lipo -create build/Release-iphoneos/libMoPubSDK.a -output libMoPubSDKDevice.a

# Build library, that can be used for simulator and device
lipo -create libMoPubSDKSimulator.a libMoPubSDKDevice.a -output libMoPubSDK.a
rm libMoPubSDKSimulator.a
rm libMoPubSDKDevice.a

mkdir $MOPUB_OUTPUT_FOLDER

mv libMoPubSDK.a $MOPUB_OUTPUT_FOLDER/
lipo -info $MOPUB_OUTPUT_FOLDER/libMoPubSDK.a
rsync -avt MoPubSDK/* \
  --exclude .DS_Store \
  --exclude *.m\
  $MOPUB_OUTPUT_FOLDER

# Do not include Viewability SDKs by default
rm -r $MOPUB_OUTPUT_FOLDER/Viewability/MOAT
rm -r $MOPUB_OUTPUT_FOLDER/Viewability/Avid

