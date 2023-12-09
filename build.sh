#!/bin/bash
set -xeu

if [ -f /.dockerenv ]; then

    export http_proxy=http://192.168.32.10:3128/
    export https_proxy=http://192.168.32.10:3128/
    export HTTP_PROXY=http://192.168.32.10:3128/
    export HTTPS_PROXY=http://192.168.32.10:3128/
    apt-get update
    apt-get -y install live-build git

    cd my_image

    lb clean
    lb config
    lb build

    sha256sum live-image-amd64.hybrid.iso > live-image-amd64.hybrid.iso.SHA256
    cat live-image-amd64.hybrid.iso.SHA256
    find . -name 'live-image-amd64.hybrid.iso*' -ls

    exit

else

    docker run --rm -it --privileged \
      -w /project \
      -v $(pwd):/project \
      debian:bookworm-slim \
      /bin/bash build.sh

    exit

fi
