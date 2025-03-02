#!/bin/bash

RELEASES_DIR=./releases/guppyscreen
rm -rf $RELEASES_DIR
mkdir -p $RELEASES_DIR

ASSET_NAME=$1

"$CROSS_COMPILE"strip ./build/bin/guppyscreen
cp ./build/bin/guppyscreen $RELEASES_DIR/guppyscreen
cp -r ./themes $RELEASES_DIR
cp guppyscreen.json $RELEASES_DIR
if [ "$ASSET_NAME" = "guppyscreen-smallscreen" ]; then
    sed -i 's/"display_rotate": 3/"display_rotate": 2/g' $RELEASES_DIR/guppyscreen.json
fi
tar czf $ASSET_NAME.tar.gz -C releases .
