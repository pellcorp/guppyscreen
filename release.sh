#!/bin/bash

RELEASES_DIR=./releases/guppyscreen
rm -rf $RELEASES_DIR
mkdir -p $RELEASES_DIR

ASSET_NAME=$1

"$CROSS_COMPILE"strip ./build/bin/guppyscreen
cp ./build/bin/guppyscreen $RELEASES_DIR/guppyscreen
cp -r ./themes $RELEASES_DIR

echo "{\"version\": \"$GUPPYSCREEN_VERSION\", \"theme\": \"$GUPPY_THEME\", \"asset_name\": \"$ASSET_NAME.tar.gz\"}" > $RELEASES_DIR/.version
tar czf $ASSET_NAME.tar.gz -C releases .