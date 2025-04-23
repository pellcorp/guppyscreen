#!/bin/bash

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd -P)"

PRINTER_IP=
SETUP=false
TARGET=mips

GIT_REVISION=$(git rev-parse --short HEAD)
GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

function docker_make() {
    target_arg=""
    if [ -n "$GUPPY_SMALL_SCREEN" ]; then
        target_arg="GUPPY_SMALL_SCREEN=true GUPPY_CALIBRATE=true"
    fi
    if [ "$TARGET" = "mips" ]; then
        target_arg+="GUPPY_FACTORY_RESET=true"
    fi

    docker run -ti -v $PWD:$PWD pellcorp/guppydev /bin/bash -c "cd $PWD && GUPPYSCREEN_VERSION=$GIT_REVISION GUPPYSCREEN_BRANCH=$GIT_BRANCH $target_arg CROSS_COMPILE=$CROSS_COMPILE make $@"
}

unset GUPPY_SMALL_SCREEN

while true; do
    if [ "$1" = "--setup" ]; then
        shift
        SETUP=true
        TARGET=$1
        if [ -z "$TARGET" ]; then
          echo "ERROR: mips or rpi target must be specified"
          exit 1
        fi
        shift
        if [ "$TARGET" = "rpi" ]; then
          echo "rpi" > $CURRENT_DIR/.target.cfg
        else
          echo "mips" > $CURRENT_DIR/.target.cfg
        fi

    elif [ "$1" = "--small" ]; then
        export GUPPY_SMALL_SCREEN=true
        shift
    elif [ "$1" = "--printer" ]; then
        shift
        PRINTER_IP=$1
        shift
    else
        break
    fi
done

if [ -f $CURRENT_DIR/.target.cfg ]; then
  TARGET=$(cat $CURRENT_DIR/.target.cfg)
fi

if [ "$TARGET" = "rpi" ]; then
  export CROSS_COMPILE=armv8-rpi3-linux-gnueabihf-
else
  export CROSS_COMPILE=mipsel-buildroot-linux-musl-
fi

if [ "$SETUP" = "true" ]; then
    docker_make spdlogclean || exit $?
    docker_make libhvclean || exit $?
    docker_make wpaclean || exit $?
    docker_make clean || exit $?

    docker_make libhv.a || exit $?
    docker_make wpaclient || exit $?
    docker_make libspdlog.a || exit $?
else
    docker_make $1 || exit $?

    if [ -n "$PRINTER_IP" ] && [ -f build/bin/guppyscreen ]; then
        if [ "$TARGET" = "mips" ]; then
          sshpass -p 'creality_2023' scp build/bin/guppyscreen root@$PRINTER_IP:
          sshpass -p 'creality_2023' scp guppyscreen.json root@$PRINTER_IP:
          sshpass -p 'creality_2023' ssh root@$PRINTER_IP "mv /root/guppyscreen /usr/data/guppyscreen/"
          sshpass -p 'creality_2023' ssh root@$PRINTER_IP "mv /root/guppyscreen.json /usr/data/guppyscreen/"
          sshpass -p 'creality_2023' ssh root@$PRINTER_IP "/etc/init.d/S99guppyscreen restart"
        else # rpi
          sshpass -p 'raspberry' scp build/bin/guppyscreen pi@$PRINTER_IP:/tmp/
          cp guppyscreen.json /tmp
          sed -i 's/"display_rotate": 3/"display_rotate": 0/g' /tmp/guppyscreen.json
          sed -i '/S58factoryreset/d' /tmp/guppyscreen.json
          sed -i 's:/usr/data/printer_data/thumbnails:/home/pi/printer_data/thumbnails:g' /tmp/guppyscreen.json
          sshpass -p 'raspberry' scp /tmp/guppyscreen.json pi@$PRINTER_IP:/tmp/
          sshpass -p 'raspberry' ssh pi@$PRINTER_IP "mv /tmp/guppyscreen /home/pi/grumpyscreen/"
          sshpass -p 'raspberry' ssh pi@$PRINTER_IP "mv /tmp/guppyscreen.json /home/pi/grumpyscreen/"
          sshpass -p 'raspberry' ssh pi@$PRINTER_IP "sudo systemctl restart grumpyscreen"
        fi
    fi
fi
