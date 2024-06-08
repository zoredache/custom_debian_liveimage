#!/bin/bash
set -xeuo pipefail

export http_proxy=http://cache.ops.zoredache.info:3128/
export https_proxy=${http_proxy}
export HTTP_PROXY=${http_proxy}
export HTTPS_PROXY=${http_proxy}

if [ -f /.dockerenv ]; then

    apt-get update
    apt-get -y install live-build git rsync

    BUILDIR="$(pwd)/my_image"
    TMPDIR=$(mktemp -d)
    rsync -va ${BUILDIR}/. ${TMPDIR}/. --exclude 'live-image-amd64.hybrid.**'
    cd ${TMPDIR}

    lb clean
    lb config
    lb build

    sha256sum live-image-amd64.hybrid.iso > live-image-amd64.hybrid.iso.SHA256
    cat live-image-amd64.hybrid.iso.SHA256
    find . -name 'live-image-amd64.hybrid.iso*' -ls

    cp ${TMPDIR}/live-image-amd64.hybrid.iso \
       ${BUILDIR}/live-image-amd64.hybrid.iso
    cp ${TMPDIR}/live-image-amd64.hybrid.iso.SHA256 \
       ${BUILDIR}/live-image-amd64.hybrid.iso.SHA256

    exit

else

    docker run --rm -it \
      --cap-add=SYS_CHROOT --cap-add SYS_ADMIN --cap-add MKNOD \
      -w /project \
      -v $(pwd):/project \
      debian:bookworm-slim \
      /bin/bash build.sh

    exit

fi
