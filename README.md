Upstream Docs

- https://manpages.debian.org/unstable/live-build/index.html
- https://salsa.debian.org/live-team/live-images/-/tree/debian/
- https://live-team.pages.debian.net/live-manual/html/live-manual/index.en.html
- https://wiki.debian.org/DebianLive

Steps to build the custom image if you have docker installed

- Clone this repo to your local system
- Change into the directory
- Edit build.sh, and change or comment out proxy
- Run build.sh

Steps followed to create this custom image

    apt-get update && apt-get -y install live-build git

    git config --global --add safe.directory /project
    git config --global user.email "zoredache@gmail.com"
    git config --global user.name "Chris Francy"

    git init --initial-branch=main
    git submodule add -b debian --name debian.live-team.live-images https://salsa.debian.org/live-team/live-images.git salsa.debian.org.live-team.live-images
    git commit -m 'add debian official livecd repo as submodule'

    mkdir my_image
    rsync -va salsa.debian.org.live-team.live-images/images/standard/. my_image/.
    git add my_image/
    git commit -m 'start from debian standard'

    # make customizations

    ...

    # commit added/changed files
    git add README.md
    git add build.sh
    git add my_image/auto/config
    git add my_image/config/hooks/normal/0500-install-zfs.chroot
    git add my_image/config/includes.chroot/
    git add my_image/config/includes.chroot/etc/console-setup/cached_setup_font.sh
    git add my_image/config/includes.chroot/etc/default/console-setup
    git add my_image/config/includes.chroot/etc/ssh/sshd_config.d/password_auth.conf
    git add my_image/config/includes.chroot/etc/tmux.conf
    git add my_image/config/package-lists/console-setup.list.chroot
    git add my_image/config/package-lists/mytools.list.chroot
    git add my_image/config/preseed/preseed.cfg.chroot
    git commit -m 'Customizations for my image'

Copy the isos

    cp -v my_image/live-image-amd64.hybrid.is* /mnt/d/Hyper-V/
