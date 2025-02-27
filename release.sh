#!/bin/bash

RELEASES_DIR=./releases/guppyscreen
rm -rf $RELEASES_DIR
mkdir -p $RELEASES_DIR

ASSET_NAME=$1

"$CROSS_COMPILE"strip ./build/bin/guppyscreen
cp ./build/bin/guppyscreen $RELEASES_DIR/guppyscreen
cp -r ./themes $RELEASES_DIR
cp guppyscreen.json $RELEASES_DIR
tar czf $ASSET_NAME.tar.gz -C releases .
