#!/bin/bash
set -xeuo pipefail

# you can run with http_proxy=http://foo ./build.sh
export http_proxy=${http_proxy:=http://example:3128/}
export https_proxy=${http_proxy}
export HTTP_PROXY=${http_proxy}
export HTTPS_PROXY=${http_proxy}

if [ -f /.dockerenv ]; then

    apt-get update
    apt-get -y install live-build git rsync

    BUILDIR="$(pwd)/my_image"
    TMPDIR=$(mktemp -d)
    rsync -va ${BUILDIR}/. ${TMPDIR}/. --exclude 'live-image-amd64.hybrid.**'
    chown root:root -R \
      ${TMPDIR}/config/includes.chroot/root/ \
      ${TMPDIR}/config/includes.chroot/etc/ssh/
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
    chown --reference ${BUILDIR} \
       ${BUILDIR}/live-image-amd64.hybrid.iso \
       ${BUILDIR}/live-image-amd64.hybrid.iso.SHA256
    exit

else

    # inject known_hosts
    mkdir -p my_image/config/includes.chroot/etc/ssh/
    grep @cert-authority /etc/ssh/ssh_known_hosts ~/.ssh/known_hosts -h | \
      sort -u > my_image/config/includes.chroot/etc/ssh/ssh_known_hosts
    # inject authorized_keys
    mkdir -p my_image/config/includes.chroot/root/.ssh/
    cat ~/.ssh/authorized_keys | \
      sort -u > my_image/config/includes.chroot/root/.ssh/authorized_keys

    # build with docker
    docker run --rm -it \
      --cap-add=SYS_CHROOT --cap-add SYS_ADMIN --cap-add MKNOD \
      -w /project \
      -e http_proxy=${http_proxy} \
      -v $(pwd):/project \
      debian:bookworm-slim \
      /bin/bash build.sh

    exit

fi
