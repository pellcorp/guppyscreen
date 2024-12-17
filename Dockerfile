FROM ubuntu:22.04

RUN DEBIAN_FRONTEND=noninteractive apt-get update && \
    apt-get install -y --no-install-recommends wget build-essential cmake git zip ca-certificates && update-ca-certificates && \
    apt-get clean all && \
    apt-get -y autoremove

RUN mkdir /toolchains && \
    wget https://toolchains.bootlin.com/downloads/releases/toolchains/mips32el/tarballs/mips32el--musl--stable-2024.02-1.tar.bz2 -O /tmp/mips32el--musl--stable-2024.02-1.tar.bz2 && \
    tar -jxf /tmp/mips32el--musl--stable-2024.02-1.tar.bz2 -C /toolchains && \
    rm /tmp/mips32el--musl--stable-2024.02-1.tar.bz2
ENV PATH=/toolchains/mips32el--musl--stable-2024.02-1/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
WORKDIR /toolchains
CMD ["/bin/bash"]
